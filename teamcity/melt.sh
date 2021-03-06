#!/bin/bash

# This script is used by teamcity to retrieve the melt script and run it
# Author: Brian Matherly
# License: GPL2

set -o nounset
set -o errexit

# Get Script
wget --no-check-certificate http://raw.github.com/mltframework/mlt-scripts/master/build/build-melt.sh
echo 'INSTALL_DIR="$(pwd)/melt"' >> build-melt.conf
echo 'AUTO_APPEND_DATE=0' >> build-melt.conf
echo 'SOURCE_DIR="$(pwd)/src"' >> build-melt.conf
chmod 755 build-melt.sh

# Run Script
./build-melt.sh 2>&1 | tee -a output.txt

# Check for need to retry
if grep output.txt "Unable to git clone source for"
then
   minutes=60
   while [ $minutes -gt 0 ]; do
      echo "Git clone failed. Retrying in $minutes minutes."
      sleep 60
      minutes=$((minutes-1))
   done
   ./build-melt.sh
fi

# Create Archive
tar -cjvf melt.tar.bz2 melt
rm -Rf melt src build-melt.conf build-melt.sh output.txt
