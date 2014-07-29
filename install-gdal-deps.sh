#!/bin/env sh

##
# Install GDAL source dependencies
#

# Set up postgres
service postgresql start || exit 1
sudo -u postgres psql -c "create database autotest" || exit 1
sudo -u postgres psql -c "create extension postgis" -d autotest || exit 1
sudo -u postgres psql -c "create extension postgis_topology" -d autotest || exit 1

# Set up mysql
mysqld_safe || exit 1 &         # fire up the server
sleep 15s                       # give it time to get up
mysql -e "create database autotest;" || exit 1
mysql -e "GRANT ALL ON autotest.* TO 'root'@'localhost';" -u root || exit 1
mysql -e "GRANT ALL ON autotest.* TO 'travis'@'localhost';" -u root || exit 1

# Get source packages
cd /tmp/ && \
    wget -q http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/FileGDB_API_1_2-64.tar.gz && \
    wget -q http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44.tar.gz && \
    wget -q http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/install-libecwj2-ubuntu12.04-64bit.tar.gz && \
    wget -q http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/install-libkml-r864-64bit.tar.gz && \
    wget -q http://s3.amazonaws.com/etc-data.koordinates.com/gdal-travisci/install-openjpeg-2.0.0-ubuntu12.04-64bit.tar.gz || exit 1

# Install MrSID
tar xzf MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44.tar.gz && \
    cp -r MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44/Raster_DSDK/include/* /usr/local/include && \
    cp -r MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44/Raster_DSDK/lib/* /usr/local/lib && \
    cp -r MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44/Lidar_DSDK/include/* /usr/local/include && \
    cp -r MrSID_DSDK-8.5.0.3422-linux.x86-64.gcc44/Lidar_DSDK/lib/* /usr/local/lib || exit 1

# Install FileGDB
tar xzf FileGDB_API_1_2-64.tar.gz && \
    cp -r FileGDB_API/include/* /usr/local/include && \
    cp -r FileGDB_API/lib/* /usr/local/lib || exit 1

# Install libecwj2
tar xzf install-libecwj2-ubuntu12.04-64bit.tar.gz && \
    cp -r install-libecwj2/include/* /usr/local/include && \
    cp -r install-libecwj2/lib/* /usr/local/lib || exit 1

# Install libkml
tar xzf install-libkml-r864-64bit.tar.gz && \
    cp -r install-libkml/include/* /usr/local/include && \
    cp -r install-libkml/lib/* /usr/local/lib || exit 1

# Install openjpeg
tar xzf install-openjpeg-2.0.0-ubuntu12.04-64bit.tar.gz && \
    cp -r install-openjpeg/include/* /usr/local/include && \
    cp -r install-openjpeg/lib/* /usr/local/lib || exit 1

ldconfig
