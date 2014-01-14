# Dockerfile for GDAL

This contains a Dockerfile which creates an Ubuntu derived docker
image.  The image contains the latest GDAL github checkout compiled
with a broad range of drivers.  The build process closely follows that
defined in <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml> but
omits Java support.

See the [Docker Index](https://index.docker.io/u/homme/gdal) for more
information.
