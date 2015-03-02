#!/bin/sh

die() {
    exit 1
}

# Reference the postgres repository
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > \
    /etc/apt/sources.list.d/pgdg-source.list || die

# Import the repository signing key, and update the package lists 
wget --no-verbose -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  apt-key add - || die
apt-get update -y || die

# Install postgres
apt-get install -y postgresql-9.4 || die
