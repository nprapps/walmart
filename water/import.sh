#!/bin/bash

psql walmart -c "DROP TABLE water;"

for f in **/*.shp
do
    ogr2ogr -append -f PostgreSQL PG:"dbname=walmart" $f -nlt MULTIPOLYGON -nln water -progress -t_srs EPSG:4269 -lco ENCODING=UTF-8
done
