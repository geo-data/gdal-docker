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

# Set the locale. Required for subversion to work on the repository.
update-locale LANG="C.UTF-8"
dpkg-reconfigure locales
. /etc/default/locale
export LANG

# Instell prerequisites.
apt-get update -y
apt-get install -y \
        software-properties-common \
        wget \
        unzip \
        subversion \
        ccache \
        clang-3.5 \
        patch \
        python-dev \
        ant

# Everything happens under here.
cd /tmp

# Get GDAL.
svn checkout --quiet "http://svn.osgeo.org/gdal/${GDAL_VERSION}/" /tmp/gdal/

# Install GDAL.
cd /tmp/gdal

# Apply our build patches.
patch ./gdal/ci/travis/trusty_clang/before_install.sh ${DIR}/before_install.sh.patch
patch ./gdal/ci/travis/trusty_clang/install.sh ${DIR}/install.sh.patch

# Do the build.
. ./gdal/ci/travis/trusty_clang/before_install.sh
. ./gdal/ci/travis/trusty_clang/install.sh

# Clean up.
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/partial/* /tmp/* /var/tmp/*
