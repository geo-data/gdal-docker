#!/bin/env sh

##
# Obtain, configure and install GDAL
#

checkout=`cat /usr/local/share/gdal-checkout.txt`

# Checkout GDAL from github
cd /
svn checkout "https://svn.osgeo.org/gdal/${checkout}/" /usr/local/src/gdal

# Configure GDAL
cd /usr/local/src/gdal/gdal
./configure --prefix=/usr/local \
            --without-libtool \
            --enable-debug \
            --with-jpeg12 \
            --with-python \
            --with-poppler \
            --with-podofo \
            --with-spatialite \
            --with-mysql \
            --with-liblzma \
            --with-webp \
            --with-epsilon \
            --with-gta \
            --with-ecw=/usr/local \
            --with-mrsid=/usr/local \
            --with-mrsid-lidar=/usr/local \
            --with-fgdb=/usr/local \
            --with-libkml \
            --with-openjpeg=/usr/local

# Make and install
make
cd apps
make test_ogrsf
cd ..
cd swig/perl
make generate
make
cd ../..
rm -f /usr/lib/libgdal.so*
make install
ldconfig
cd ../autotest/cpp
make
