#!/bin/env sh

##
# Run the GDAL autotest suite
#
# This is based on instructions at
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml>.
#

die() {
    exit 1
}

# Install test dependencies.
apt-get install -y sqlite3 || die

# Start the required services
service postgresql start || die
service mysql start || die

# Change to the correct directory.
cd /tmp/gdal/gdal || die

# The following is closely adapted from .travis.yml:

# Perl unit tests
cd swig/perl || die
make test
cd ../.. || die
# Java unit tests
cd swig/java || die
make test
cd ../.. || die
# CPP unit tests
cd ../autotest || die
cd cpp || die
GDAL_SKIP=JP2ECW make quick_test
# Compile and test vsipreload
make vsipreload.so || die
LD_PRELOAD=./vsipreload.so gdalinfo /vsicurl/http://download.osgeo.org/gdal/data/ecw/spif83.ecw || die
LD_PRELOAD=./vsipreload.so sqlite3  /vsicurl/http://download.osgeo.org/gdal/data/sqlite3/polygon.db "select * from polygon limit 10" || die
cd .. || die
# Download a sample file
mkdir -p ogr/tmp/cache/ || die
cd ogr/tmp/cache/ || die
wget --no-verbose http://download.osgeo.org/gdal/data/pgeo/PGeoTest.zip || die
unzip PGeoTest.zip || die
cd ../../.. || die
# Run ogr_fgdb.py in isolation from the rest
cd ogr || die
python ogr_fgdb.py || die
mkdir disabled || die
mv ogr_fgdb.* disabled || die
cd .. || die
# Run ogr_pgeo.py in isolation from the rest
cd ogr || die
python ogr_pgeo.py || die
mv ogr_pgeo.* disabled || die
cd .. || die
# Run all the Python autotests
GDAL_SKIP="JP2ECW ECW" python run_all.py
# A bit messy, but force testing with libspatialite 4.0dev (that has been patched a bit to remove any hard-coded SRS definition so it is very small)
cd ogr || die
wget --no-verbose http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/libspatialite4.0dev_ubuntu12.04-64bit_srs_stripped.tar.gz || die
tar xzf libspatialite4.0dev_ubuntu12.04-64bit_srs_stripped.tar.gz || die
ln -s install-libspatialite-4.0dev/lib/libspatialite.so.5.0.1 libspatialite.so.3 || die
LD_LIBRARY_PATH=$PWD python ogr_sqlite.py || die

# Stop previously started services.
service mysql stop
service postgresql stop
