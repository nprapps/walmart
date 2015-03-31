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

if ! [ -f chicago_illinois.osm2pgsql-shapefiles.zip ]; then
    curl -O https://s3.amazonaws.com/metro-extracts.mapzen.com/chicago_illinois.osm2pgsql-shapefiles.zip
    unzip chicago_illinois.osm2pgsql-shapefiles.zip -d shp/chicago_illinois.osm2pgsql-shapefiles
fi

if ! [ -f dc-baltimore_maryland.osm2pgsql-shapefiles.zip ]; then
    curl -O https://s3.amazonaws.com/metro-extracts.mapzen.com/dc-baltimore_maryland.osm2pgsql-shapefiles.zip
    unzip dc-baltimore_maryland.osm2pgsql-shapefiles.zip -d shp/dc-baltimore_maryland.osm2pgsql-shapefiles
fi

if ! [ -f atlanta_georgia.osm2pgsql-shapefiles.zip ]; then
    curl -O https://s3.amazonaws.com/metro-extracts.mapzen.com/atlanta_georgia.osm2pgsql-shapefiles.zip
    unzip atlanta_georgia.osm2pgsql-shapefiles.zip -d shp/atlanta_georgia.osm2pgsql-shapefiles
fi

# Water

# WATER=(
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/11_District_of_Columbia/11001/tl_2010_11001_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/24_Maryland/24031/tl_2010_24031_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/24_Maryland/24033/tl_2010_24033_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/51_Virginia/51059/tl_2010_51059_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/17_Illinois/17031/tl_2010_17031_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/17_Illinois/17043/tl_2010_17043_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/18_Indiana/18089/tl_2010_18089_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/13_Georgia/13067/tl_2010_13067_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/13_Georgia/13089/tl_2010_13089_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/13_Georgia/13121/tl_2010_13121_areawater.zip
#     ftp://ftp2.census.gov/geo/pvs/tiger2010st/13_Georgia/13135/tl_2010_13135_areawater.zip
# )
#
# for water in "${WATER[@]}"
# do
#     curl -O http://www2.census.gov/geo/tiger/TIGER2010/PLACE/2010/tl_2010_${fips}_place10.zip
#         unzip tl_2010_${fips}_place10.zip -d shp/tl_2010_${fips}_place10
#     fi
# done
