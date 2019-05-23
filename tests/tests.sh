#!/usr/bin/env bash
set -e

echo "looking that some formats are available"
echo

echo "is ogr LIBKML available:"
ogrinfo --formats | grep LIBKML
echo

echo "is ogr FileGDB available:"
ogrinfo --formats | grep FileGDB | grep rw+
echo

echo "is gdal GeoTIFF available:"
gdalinfo --formats | grep GeoTIFF
echo

echo "do the python bindings work:"

python3 gdal_python_3_tests.py
echo
