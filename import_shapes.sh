#!/bin/bash

source globals.sh

echo "Importing Census blocks"

psql walmart -c "DROP TABLE blocks;"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};

    echo "* ${name}"
    ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/tabblock2010_${fips}_pophu/tabblock2010_${fips}_pophu.shp -nlt MULTIPOLYGON -nln blocks -progress -t_srs EPSG:4269
done

echo "Import Census places"

psql walmart -c "DROP TABLE places;"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};

    echo "* ${name}"
    ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/tl_2010_${fips}_place10/tl_2010_${fips}_place10.shp -nlt MULTIPOLYGON -nln places -progress -t_srs EPSG:4269
done
