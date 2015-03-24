#!/bin/bash

source globals.sh

echo "Importing Census blocks"

psql walmart -c "DROP TABLE blocks;"

for fips in "${FIPS[@]}"
do
    echo "${fips}"
    ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/tabblock2010_${fips}_pophu/tabblock2010_${fips}_pophu.shp -nlt MULTIPOLYGON -nln blocks -progress -t_srs EPSG:4269
done

echo "Import city outlines"

echo "Atlanta"
psql walmart -c "DROP TABLE atlanta_city_limits;"
ogr2ogr -f PostgreSQL PG:"dbname=walmart" shp/ATL_POLITIC_ATLANTA_CITY_LIMITS/ATL_POLITIC_ATLANTA_CITY_LIMITS.shp -nlt MULTIPOLYGON -nln atlanta_city_limits -progress -lco PRECISION=NO -t_srs EPSG:4269
