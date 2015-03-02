#!/bin/env sh

##
# Configure and install GDAL
#
# This is based on instructions at
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml>.
#

die() {
    exit 1
}

# Install build dependencies.
apt-get install -y python-dev ant || die

# Change to the source directory
cd /tmp/gdal || die

# The following is closely adapted from .travis.yml:

cd gdal || die
./configure --prefix=/usr/local --without-libtool --enable-debug --with-jpeg12 --with-python --with-poppler --with-podofo --with-spatialite --with-mysql --with-liblzma --with-webp --with-java --with-mdb --with-jvm-lib-add-rpath --with-epsilon --with-gta --with-ecw=/usr/local --with-mrsid=/usr/local --with-mrsid-lidar=/usr/local --with-fgdb=/usr/local --with-libkml --with-openjpeg=/usr/local || die
make -j3 || die
cd apps || die
make test_ogrsf || die
cd .. || die
cd swig/java || die
cat java.opt | sed "s/JAVA_HOME =.*/JAVA_HOME = \/usr\/lib\/jvm\/java-7-openjdk-amd64\//" > java.opt.tmp || die
mv java.opt.tmp java.opt || die
make || die
cd ../.. || die
cd swig/perl || die
make generate || die
make || die
cd ../.. || die
rm -f /usr/lib/libgdal.so* || die
make install || die
ldconfig || die
cd ../autotest/cpp || die
make -j3 || die
cd ../../gdal || die
wget --no-verbose http://mdb-sqlite.googlecode.com/files/mdb-sqlite-1.0.2.tar.bz2 || die
tar xjvf mdb-sqlite-1.0.2.tar.bz2 || die
cp mdb-sqlite-1.0.2/lib/*.jar /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext || die
