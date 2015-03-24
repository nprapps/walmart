#!/bin/bash

source globals.sh

echo "Downloading state block shapefiles"

for fips in "${FIPS[@]}"
do
    echo "${fips}"
    if ! [ -f tabblock2010_${fips}_pophu.zip ]; then
        curl -O http://www2.census.gov/geo/tiger/TIGER2010BLKPOPHU/tabblock2010_${fips}_pophu.zip
        unzip tabblock2010_${fips}_pophu.zip -d shp/tabblock2010_${fips}_pophu
    fi
done

echo "Downloading city outline shapefiles"

echo "Atlanta"

# Atlanta
if ! [ -f ATL_POLITIC_ATLANTA_CITY_LIMITS.zip ]; then
    curl -O http://gis.atlantaga.gov/apps/gislayers/download/layers/ATL_POLITIC_ATLANTA_CITY_LIMITS.zip
    unzip ATL_POLITIC_ATLANTA_CITY_LIMITS.zip -d shp/ATL_POLITIC_ATLANTA_CITY_LIMITS
fi
