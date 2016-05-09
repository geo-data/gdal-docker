[![](https://imagelayers.io/badge/geometalab/gdal-docker:latest.svg)](https://imagelayers.io/?images=geometalab/gdal-docker:latest 'Get your own badge on imagelayers.io')
[![Circle CI](https://circleci.com/gh/geometalab/gdal-docker.svg?style=svg)](https://circleci.com/gh/geometalab/gdal-docker)
[![Stories in Ready](https://badge.waffle.io/geometalab/gdal-docker.svg?label=ready&title=Ready)](http://waffle.io/geometalab/gdal-docker)

# GDAL Docker Images

This is an Ubuntu derived image containing the Geospatial Data Abstraction
Library (GDAL) compiled with a broad range of drivers. The build process is
based on that defined in the
[GDAL TravisCI tests](https://github.com/OSGeo/gdal/blob/trunk/.travis.yml).
You can find the image [geometalab/gdal-docker][dockerimage] on dockerhub.

[dockerimage]: https://hub.docker.com/r/geometalab/gdal-docker/

## Usage

Running the container without any arguments will by default output the GDAL
version string as well as the supported raster and vector formats:
```
docker run --rm -ti geometalab/gdal-docker
```
will output something like:
```
GDAL 2.2.0dev, released 2016/99/99
Supported Formats:
  VRT -raster- (rw+v): Virtual Raster
  GTiff -raster- (rw+vs): GeoTIFF
  NITF -raster- (rw+vs): National Imagery Transmission Format
  RPFTOC -raster- (rovs): Raster Product Format TOC format
  ...
```

The following command will open a bash shell in an Ubuntu based environment
with GDAL available:

    docker run --rm -ti geometalab/gdal-docker /bin/bash

You will most likely want to work with `data` on the host system from within the
docker container, in which case run the container with the `--volume` option. Assuming
you have a raster called `test.tif` in your current working directory on your
host system, running the following command should invoke `gdalinfo` on
`test.tif`:

    docker run --rm -ti --volume $(pwd):/data geometalab/gdal-docker gdalinfo test.tif

This works because the current working directory is set to `/data` in the
container, and you have mapped the current working directory on your host to
`/data`.

GDAL will be run under user `nobody` in the container, so if editing or creating
files the appropriate permissions for that user must be applied to the directory
pointed to by `$(pwd)`.  Alternatively pass the `--user` option to `docker run`.

Note that the image tagged `latest`, GDAL represents the latest code *at the
time the image was built*. If you want to include the most up-to-date commits
then you need to build the docker image yourself locally along these lines:

    docker build -t geometalab/gdal-docker:local git://github.com/geometalab/gdal-docker.git
