#!/bin/env sh

##
# Configure and install GDAL
#

checkout=`cat /tmp/gdal-checkout.txt`

# Checkout GDAL from github
cd / && \
    svn checkout "https://svn.osgeo.org/gdal/${checkout}/" /tmp/gdal || exit 1
