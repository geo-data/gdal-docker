##
# geometalab/gdal-docker
#
# This creates an Ubuntu derived base image that installs the latest GDAL
# subversion checkout compiled with a broad range of drivers.  The build process
# is based on that defined in
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml>
#

# Ubuntu 14.04 Trusty Tahyr
FROM ubuntu:trusty

MAINTAINER Geometalab <geometalab@hsr.ch>

# Install the application.
ADD . /usr/local/src/gdal-docker/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends make && \
    make -C /usr/local/src/gdal-docker install clean && \
    apt-get purge -y make && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/partial/* /tmp/* /var/tmp/*

# Externally accessible data is by default put in /data
WORKDIR /data
VOLUME ["/data"]

# Execute the gdal utilities as nobody, not root
USER nobody

# Output version and capabilities by default.
CMD gdalinfo --version && gdalinfo --formats && ogrinfo --formats
