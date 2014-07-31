##
# homme/gdal
#
# This creates an Ubuntu derived base image that installs the latest GDAL
# subversion checkout compiled with a broad range of drivers.  The build
# process closely follows that defined in
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml> but omits Java
# support.
#

# Ubuntu 13.10
FROM ubuntu:saucy

MAINTAINER Homme Zwaagstra <hrz@geodata.soton.ac.uk>

# Ensure the package repository is up to date
RUN apt-get update -y

# Temporarily hack around a docker build issue. See
# <https://github.com/docker/docker/issues/6345#issuecomment-49245365>.
RUN ln -s -f /bin/true /usr/bin/chfn

# Install basic dependencies
RUN apt-get install -y \
    software-properties-common \
    python-software-properties \
    build-essential \
    wget \
    subversion

# Install the ubuntu gis repository
RUN add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
RUN add-apt-repository -y ppa:marlam/gta

# Install postgis (see http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS21UbuntuPGSQL93Apt)
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" >> /etc/apt/sources.list'
RUN wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -

RUN apt-get update -y

RUN apt-get install -y \
    postgresql-9.3 \
    postgresql-9.3-postgis \
    postgresql-contrib

# a mounted file systems table to make MySQL happy
#RUN cat /proc/mounts > /etc/mtab

# Install gdal dependencies provided by Ubuntu repositories
RUN apt-get install -y \
    mysql-server \
    mysql-client \
    python-numpy \
    libpq-dev \
    libpng12-dev \
    libjpeg-dev \
    libgif-dev \
    liblzma-dev \
    libgeos-dev \
    libcurl4-gnutls-dev \
    libproj-dev \
    libxml2-dev \
    libexpat-dev \
    libxerces-c-dev \
    libnetcdf-dev \
    netcdf-bin \
    libpoppler-dev \
    libspatialite-dev \
    gpsbabel \
    swig \
    libhdf4-alt-dev \
    libhdf5-serial-dev \
    libpodofo-dev \
    poppler-utils \
    libfreexl-dev \
    unixodbc-dev \
    libwebp-dev \
    libepsilon-dev \
    libgta-dev \
    liblcms2-2 \
    libpcre3-dev \
    python-dev \
    sudo

# Install the GDAL source dependencies
ADD ./install-gdal-deps.sh /tmp/
RUN sh /tmp/install-gdal-deps.sh

# Install GDAL itself
ADD ./gdal-checkout.txt /tmp/gdal-checkout.txt
ADD ./install-gdal.sh /tmp/
RUN sh /tmp/install-gdal.sh

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Run the GDAL test suite by default
CMD cd /usr/local/share/gdal-autotest && ./run_all.py
