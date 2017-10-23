#!/bin/sh

##
# Install GDAL from within a docker container
#
# This script is designed to be run from within a docker container in order to
# install GDAL. It delegates to `before_install.sh` and `install.sh` which are
# patched from the Travis CI configuration in the GDAL repository.
#

set -e

DIR=$(dirname "$(readlink -f "$0")")
GDAL_VERSION=$(cat ${DIR}/gdal-checkout.txt)

export DEBIAN_FRONTEND=noninteractive

# Instell prerequisites.
apt-get update -y
apt-get install -y \
        subversion \
        sudo \
        make \
        ccache \
        software-properties-common \
        wget \
        unzip \
        build-essential

# Set the locale. Required for subversion to work on the repository.
export LANG="C.UTF-8"
apt-get install -y locales
update-locale LANG=$LANG
dpkg-reconfigure locales
. /etc/default/locale

# Everything happens under here.
cd /tmp

# Get GDAL.
svn checkout --quiet "http://svn.osgeo.org/gdal/${GDAL_VERSION}/" /tmp/gdal/

# Apply our build patches.
cd /tmp/gdal
svn patch ${DIR}/before_install.sh.patch
svn patch ${DIR}/install.sh.patch

# Install prerequisites.
yes | sh ./gdal/ci/travis/gcc48_stdcpp11/before_install.sh

# Upgrade curl to support HTTP/2.
apt-get purge -y libcurl4-gnutls-dev libcurl3-gnutls libnetcdf-dev netcdf-bin
apt-get install -y nghttp2 libnghttp2-dev
wget https://curl.haxx.se/download/curl-7.56.0.tar.bz2
tar -xvjf curl-7.56.0.tar.bz2
cd curl-7.56.0
./configure  --with-ssl --with-nghttp2 --prefix=/usr/local
make -j$(nproc)
make install
ldconfig

# Install GDAL.
cd /tmp/gdal
bash ./gdal/ci/travis/gcc48_stdcpp11/install.sh

# Clean up.
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/partial/* /tmp/* /var/tmp/*
