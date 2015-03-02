#!/bin/sh

##
# Install Postgis
#
# This is based on instructions at
# <http://trac.osgeo.org/postgis/wiki/UsersWikiPostGIS21Ubuntu1404src>.
#

die() {
    exit 1
}

# Install prerequisites
apt-get install -y \
    build-essential \
    postgresql-server-dev-9.4 \
    libgeos-c1 \
    libgdal-dev \
    libproj-dev \
    libjson0-dev \
    libxml2-dev \
    libxml2-utils \
    xsltproc \
    docbook-xsl \
    docbook-mathml \
    || die

# Get postgis
cd /tmp && \
    wget --no-verbose http://download.osgeo.org/postgis/source/postgis-2.1.5.tar.gz \
    || die
tar xfz postgis-2.1.5.tar.gz || die

# Install postgis
cd postgis-2.1.5 || die
./configure || die
make || die
make install || die
ldconfig || die
make comments-install || die

# Expose the tools
ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/shp2pgsql || die
ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/pgsql2shp || die
ln -sf /usr/share/postgresql-common/pg_wrapper /usr/local/bin/raster2pgsql || die
