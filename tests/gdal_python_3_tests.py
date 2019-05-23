#!/usr/bin/env python3


def test_imports():
    from osgeo import gdal
    from osgeo import ogr
    from osgeo import osr
    from osgeo import gdal_array
    from osgeo import gdalconst

    # Enable GDAL/OGR exceptions
    gdal.UseExceptions()


def test_ogr_formats():
    from osgeo import ogr
    ogr.UseExceptions()
    assert ogr.GetDriverByName('FileGDB')


def test_gdal_formats():
    from osgeo import gdal
    gdal.UseExceptions()
    assert gdal.GetDriverByName('FileGDB')
    assert gdal.GetDriverByName('ESRI Shapefile')
    assert gdal.GetDriverByName('GTiff')


if __name__ == '__main__':
    test_imports()
    test_ogr_formats()
    test_gdal_formats()
    # print happy message if they run through
    print("    yes, they do :-D")
