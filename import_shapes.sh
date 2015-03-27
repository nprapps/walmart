#!/bin/bash

source globals.sh

export SHAPE_ENCODING="ISO-8859-1"

echo "Importing Census blocks"

psql walmart -c "DROP TABLE blocks;"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};

    echo "* ${name}"
    ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/tabblock2010_${fips}_pophu/tabblock2010_${fips}_pophu.shp -nlt MULTIPOLYGON -nln blocks -progress -t_srs EPSG:4269 -lco ENCODING=UTF-8
done

echo "Import Census places"

psql walmart -c "DROP TABLE places;"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};

    echo "* ${name}"
    ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/tl_2010_${fips}_place10/tl_2010_${fips}_place10.shp -nlt MULTIPOLYGON -nln places -progress -t_srs EPSG:4269 -lco ENCODING=UTF-8
done

psql walmart -c "DROP TABLE osm_lines;"

ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/chicago_illinois.osm2pgsql-shapefiles/chicago_illinois.osm-line.shp -nlt MULTILINESTRING -nln osm_lines -progress -t_srs EPSG:4269 -lco ENCODING=UTF-8
ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/dc-baltimore_maryland.osm2pgsql-shapefiles/dc-baltimore_maryland.osm-line.shp -nlt MULTILINESTRING -nln osm_lines -progress -t_srs EPSG:4269 -lco ENCODING=UTF-8
ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" shp/atlanta_georgia.osm2pgsql-shapefiles/atlanta_georgia.osm-line.shp -nlt MULTILINESTRING -nln osm_lines -progress -t_srs EPSG:4269 -lco ENCODING=UTF-8
