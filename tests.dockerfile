ARG GDAL_VERSION=latest
FROM geometalab/gdal-docker:${GDAL_VERSION}
CMD bash -c "cd /tmp/tests/ && ./tests.sh"
