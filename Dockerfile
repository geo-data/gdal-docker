##
# geodata/gdal
#
# This creates an Ubuntu derived base image that installs the latest GDAL
# subversion checkout compiled with a broad range of drivers.  The build process
# is based on that defined in
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml>
#

# Ubuntu 16.04 Xenial Xerus
FROM ubuntu:xenial

MAINTAINER Homme Zwaagstra <hrz@geodata.soton.ac.uk>

# Install the application.
ADD . /usr/local/src/gdal-docker/
RUN /usr/local/src/gdal-docker/build.sh

# Externally accessible data is by default put in /data
WORKDIR /data
VOLUME ["/data"]

# Output version and capabilities by default.
CMD gdalinfo --version && gdalinfo --formats && ogrinfo --formats
