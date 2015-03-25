#!/bin/bash

source globals.sh

echo "Downloading Census block shapefiles"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};

    echo "* ${name}"
    if ! [ -f tabblock2010_${fips}_pophu.zip ]; then
        curl -O http://www2.census.gov/geo/tiger/TIGER2010BLKPOPHU/tabblock2010_${fips}_pophu.zip
        unzip tabblock2010_${fips}_pophu.zip -d shp/tabblock2010_${fips}_pophu
    fi
done

echo "Downloading Census place shapefiles"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};

    echo "* ${name}"
    if ! [ -f tl_2010_${fips}_place10.zip ]; then
        curl -O http://www2.census.gov/geo/tiger/TIGER2010/PLACE/2010/tl_2010_${fips}_place10.zip
        unzip tl_2010_${fips}_place10.zip -d shp/tl_2010_${fips}_place10
    fi
done
