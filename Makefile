##
# Install GDAL from within a docker container
#
# This Makefile is designed to be run from within a docker container in order to
# install GDAL.  The following is an example invocation:
#
# make -C /usr/local/src/gdal-docker install clean
#
# The targets in this Makefile are derived from the GDAL .travis.yml file
# (https://github.com/OSGeo/gdal/blob/trunk/.travis.yml).
#

# If grass support is required set the variable WITH_GRASS to the GRASS install
# directory.
ifdef WITH_GRASS
USE_GRASS := "--with-grass=$(WITH_GRASS)"
endif

# Version related variables.
GDAL_VERSION := $(shell cat ./gdal-checkout.txt)
OPENJPEG_DOWNLOAD := install-openjpeg-2.0.0-ubuntu12.04-64bit.tar.gz
FILEGDBAPI_DOWNLOAD := FileGDB_API_1_2-64.tar.gz
LIBECWJ2_DOWNLOAD := install-libecwj2-ubuntu12.04-64bit.tar.gz
MRSID_DIR = MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44
MRSID_DOWNLOAD := $(MRSID_DIR).tar.gz
LIBKML_DOWNLOAD := install-libkml-r864-64bit.tar.gz
LIBKEA_VERSION := c6d36f3db5e4
LIBKEA_DOWNLOAD := $(LIBKEA_VERSION).zip
MDBSQLITE_DIR := mdb-sqlite-1.0.2
MDBSQLITE_DOWNLOAD := $(MDBSQLITE_DIR).tar.bz2
MDBSQLITE_URL := https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/mdb-sqlite/

# Dependencies satisfied by packages.
DEPS_PACKAGES := python-numpy python-dev libpq-dev libpng12-dev libjpeg-dev libgif-dev liblzma-dev libgeos-dev libcurl4-gnutls-dev libproj-dev libxml2-dev libexpat-dev libxerces-c-dev libnetcdf-dev netcdf-bin libpoppler-dev libspatialite-dev gpsbabel swig libhdf4-alt-dev libpodofo-dev poppler-utils libfreexl-dev unixodbc-dev libwebp-dev libepsilon-dev libgta-dev liblcms2-2 libpcre3-dev
# Packages required by mongo.
MONGO_PACKAGES := libboost-regex-dev libboost-system-dev libboost-thread-dev libboost-regex1.55.0 libboost-system1.55.0 libboost-thread1.55.0

# GDAL dependency targets.
GDAL_CONFIG := /usr/local/bin/gdal-config
BUILD_ESSENTIAL := /usr/share/build-essential
MONGO_DEV := /usr/local/include/mongo
MONGO_DEPS := /usr/include/boost/shared_ptr.hpp # Mongo runtime dependencies.
OPENJPEG_DEV := /usr/local/include/openjpeg-2.0
FILEGDBAPI_DEV := /usr/local/include/FileGDBAPI.h
LIBECWJ2_DEV := /usr/local/include/NCSECWClient.h
MRSID_DEV := /usr/local/include/lt_base.h
LIBHDF5_DEV := /usr/include/H5Cpp.h
LIBKEA_DEV := /usr/lib/libkea.so
MDBSQLITE_DEV := $(JAVA)/jre/lib/ext/sqlitejdbc-v048-nested.jar
JAVA := /usr/lib/jvm/java-7-openjdk-amd64
DEPS_DEV := /usr/include/numpy	# Represents all dependency packages.

# Build tools.
SVN := /usr/bin/svn
WGET := /usr/bin/wget
UNZIP := /usr/bin/unzip
CMAKE := /usr/bin/cmake
GIT := /usr/bin/git
SCONS := /usr/bin/scons
ANT := /usr/bin/ant
ADD_APT_REPOSITORY := /usr/bin/add-apt-repository

# Number of processors available.
NPROC := $(shell nproc)

install: $(GDAL_CONFIG)

$(GDAL_CONFIG): /tmp/gdal $(MONGO_DEV) $(OPENJPEG_DEV) $(FILEGDBAPI_DEV) $(LIBECWJ2_DEV) $(MRSID_DEV) $(LIBKML_DEV) $(LIBKEA_DEV) $(MDBSQLITE_DEV) $(JAVA) $(DEPS_DEV) $(ANT)
	cd /tmp/gdal/gdal \
	&& ./configure \
		--prefix=/usr/local \
		--with-jpeg12 \
		--with-python \
		--with-poppler \
		--with-podofo \
		--with-spatialite \
		--with-mysql \
		--with-liblzma \
		--with-webp \
		--with-java \
		--with-mdb \
		--with-jvm-lib-add-rpath \
		--with-epsilon \
		--with-gta \
		--with-ecw=/usr/local \
		--with-mrsid=/usr/local \
		--with-mrsid-lidar=/usr/local \
		--with-fgdb=/usr/local \
		--with-libkml \
		--with-openjpeg=/usr/local \
		--with-mongocxx=/usr/local $(USE_GRASS) \
	&& make -j$(NPROC) \
	&& cd swig/java \
	&& sed -i "s/JAVA_HOME =.*/JAVA_HOME = \/usr\/lib\/jvm\/java-7-openjdk-amd64\//" java.opt \
	&& make -j$(NPROC) \
	&& cd ../../swig/perl \
	&& make generate \
	&& make -j$(NPROC) \
	&& cd ../.. \
	&& make install \
	&& ldconfig

/tmp/gdal: $(SVN) $(BUILD_ESSENTIAL)
	$(SVN) checkout --quiet "http://svn.osgeo.org/gdal/$(GDAL_VERSION)/" /tmp/gdal/ \
	&& touch -c /tmp/gdal

$(MONGO_DEV): $(GIT) $(SCONS) $(MONGO_DEPS)
	$(GIT) clone --branch legacy --depth 1 http://github.com/mongodb/mongo-cxx-driver.git /tmp/mongo-cxx-driver \
	&& cd /tmp/mongo-cxx-driver \
	&& $(SCONS) --prefix=/usr/local --sharedclient install
$(MONGO_DEPS): /tmp/apt-updated
	apt-get install -y $(MONGO_PACKAGES) && touch -c $(MONGO_DEPS)

$(OPENJPEG_DEV): /tmp/$(OPENJPEG_DOWNLOAD)
	tar -C /tmp -xzf /tmp/$(OPENJPEG_DOWNLOAD) \
	&& cp -r /tmp/install-openjpeg/include/* /usr/local/include \
	&& cp -r /tmp/install-openjpeg/lib/* /usr/local/lib
/tmp/$(OPENJPEG_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/$(OPENJPEG_DOWNLOAD) -O /tmp/$(OPENJPEG_DOWNLOAD) \
	&& touch -c /tmp/$(OPENJPEG_DOWNLOAD)

$(FILEGDBAPI_DEV): /tmp/$(FILEGDBAPI_DOWNLOAD)
	tar -C /tmp -xzf /tmp/$(FILEGDBAPI_DOWNLOAD) \
	&& cp -r /tmp/FileGDB_API/include/* /usr/local/include \
	&& cp -r /tmp/FileGDB_API/lib/* /usr/local/lib
/tmp/$(FILEGDBAPI_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/$(FILEGDBAPI_DOWNLOAD) -O /tmp/$(FILEGDBAPI_DOWNLOAD) \
	&& touch -c /tmp/$(FILEGDBAPI_DOWNLOAD)

$(LIBECWJ2_DEV): /tmp/$(LIBECWJ2_DOWNLOAD)
	tar -C /tmp -xzf /tmp/$(LIBECWJ2_DOWNLOAD) \
	&& cp -r /tmp/install-libecwj2/include/* /usr/local/include \
	&& cp -r /tmp/install-libecwj2/lib/* /usr/local/lib
/tmp/$(LIBECWJ2_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/$(LIBECWJ2_DOWNLOAD) -O /tmp/$(LIBECWJ2_DOWNLOAD) \
	&& touch -c /tmp/$(LIBECWJ2_DOWNLOAD)

$(MRSID_DEV): /tmp/$(MRSID_DOWNLOAD)
	tar -C /tmp -xzf /tmp/$(MRSID_DOWNLOAD) \
	&& cp -r /tmp/$(MRSID_DIR)/Raster_DSDK/include/* /usr/local/include \
	&& cp -r /tmp/$(MRSID_DIR)/Raster_DSDK/lib/* /usr/local/lib \
	&& cp -r /tmp/$(MRSID_DIR)/Lidar_DSDK/include/* /usr/local/include \
	&& cp -r /tmp/$(MRSID_DIR)/Lidar_DSDK/lib/* /usr/local/lib
/tmp/$(MRSID_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/$(MRSID_DOWNLOAD) -O /tmp/$(MRSID_DOWNLOAD) \
	&& touch -c /tmp/$(MRSID_DOWNLOAD)

$(LIBKML_DEV): /tmp/$(LIBKML_DOWNLOAD)
	tar -C /tmp -xzf /tmp/$(LIBKML_DOWNLOAD) \
	&& cp -r /tmp/install-libkml/include/* /usr/local/include \
	&& cp -r /tmp/install-libkml/lib/* /usr/local/lib
/tmp/$(LIBKML_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/$(LIBKML_DOWNLOAD) -O /tmp/$(LIBKML_DOWNLOAD) \
	&& touch -c /tmp/$(LIBKML_DOWNLOAD)

$(LIBKEA_DEV): /tmp/$(LIBKEA_DOWNLOAD) $(LIBHDF5_DEV) $(UNZIP) $(CMAKE)
	$(UNZIP) -o -d /tmp /tmp/$(LIBKEA_DOWNLOAD) \
	&& cd /tmp/chchrsc-kealib-$(LIBKEA_VERSION)/trunk \
	&& cmake . -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DHDF5_INCLUDE_DIR=/usr/include -DHDF5_LIB_PATH=/usr/lib -DLIBKEA_WITH_GDAL=OFF \
	&& make -j$(NPROC) \
	&& make install \
	&& ldconfig
/tmp/$(LIBKEA_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose https://bitbucket.org/chchrsc/kealib/get/$(LIBKEA_DOWNLOAD) -O /tmp/$(LIBKEA_DOWNLOAD) \
	&& touch -c /tmp/$(LIBKEA_DOWNLOAD)
$(LIBHDF5_DEV): /tmp/apt-updated
	apt-get install -y libhdf5-serial-dev && touch -c $(LIBHDF5_DEV)

$(MDBSQLITE_DEV): /tmp/$(MDBSQLITE_DOWNLOAD) $(JAVA)
	tar -C /tmp -xjf /tmp/$(MDBSQLITE_DOWNLOAD) \
	&& cp /tmp/$(MDBSQLITE_DIR)/lib/*.jar $(JAVA)/jre/lib/ext
/tmp/$(MDBSQLITE_DOWNLOAD): $(WGET)
	$(WGET) --no-verbose $(MDBSQLITE_URL)$(MDBSQLITE_DOWNLOAD) -O /tmp/$(MDBSQLITE_DOWNLOAD) \
	&& touch -c /tmp/$(MDBSQLITE_DOWNLOAD)

$(JAVA): /tmp/apt-updated
	apt-get install -y openjdk-7-jdk && touch -c $(JAVA)

$(DEPS_DEV): /etc/apt/sources.list.d/ubuntugis-ubuntugis-unstable-trusty.list /etc/apt/sources.list.d/marlam-gta-trusty.list
	apt-get install -y $(DEPS_PACKAGES) && touch -c $(DEPS_DEV)

$(SVN): /tmp/apt-updated
	apt-get install -y subversion && touch -c $(SVN)

$(WGET): /tmp/apt-updated
	apt-get install -y wget && touch -c $(WGET)

$(UNZIP): /tmp/apt-updated
	apt-get install -y unzip && touch -c $(UNZIP)

$(CMAKE): /tmp/apt-updated
	apt-get install -y cmake && touch -c $(CMAKE)

$(GIT): /tmp/apt-updated
	apt-get install -y git && touch -c $(GIT)

$(SCONS): /tmp/apt-updated
	apt-get install -y scons && touch -c $(SCONS)

$(ANT): /tmp/apt-updated
	apt-get install -y ant && touch -c $(ANT)

$(BUILD_ESSENTIAL): /tmp/apt-updated
	apt-get install -y build-essential \
	&& touch -c $(BUILD_ESSENTIAL)

/etc/apt/sources.list.d/ubuntugis-ubuntugis-unstable-trusty.list: /usr/bin/add-apt-repository
	add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable && apt-get update -y

/etc/apt/sources.list.d/marlam-gta-trusty.list: /usr/bin/add-apt-repository
	add-apt-repository -y ppa:marlam/gta && apt-get update -y

$(ADD_APT_REPOSITORY): /tmp/apt-updated
	apt-get install -y software-properties-common \
	&& touch -c $(ADD_APT_REPOSITORY)

/tmp/apt-updated:
	apt-get update -y && touch /tmp/apt-updated

# Remove build time dependencies.
clean:
	apt-get purge -y \
		software-properties-common \
		subversion \
		wget \
		build-essential \
		unzip \
		cmake \
		git \
		scons \
		ant \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/partial/* /tmp/* /var/tmp/*

.PHONY: install clean
