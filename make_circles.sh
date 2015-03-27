#!/bin/bash

source globals.sh;

psql walmart -c "DROP TABLE circles;"
psql walmart -c "CREATE TABLE circles (
    store_number integer,
    year varchar,
    range integer
);"

psql walmart -c "ALTER TABLE circles ADD COLUMN geom geometry(MULTIPOLYGON,4269);"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};
    place_fips=${PLACES["${fips}"]};
    pop=${POPS["${fips}"]};

    psql walmart -c "
        INSERT INTO circles
        SELECT
            store_number,
            year,
            1,
            ST_Multi(ST_CollectionExtract(ST_Intersection(
                ST_Transform(ST_Buffer(ST_Transform(geom, 2163), 1609.34), 4269),
                (SELECT wkb_geometry FROM places WHERE places.statefp10 = '${fips}' AND places.placefp10 = '${place_fips}')
            ), 3))
        FROM walmarts
        WHERE region='${name}';"

    psql walmart -c "
        INSERT INTO circles
        SELECT
            store_number,
            year,
            2,
            ST_Multi(ST_CollectionExtract(ST_Intersection(
                ST_Transform(ST_Buffer(ST_Transform(geom, 2163), 1609.34 * 2), 4269),
                (SELECT wkb_geometry FROM places WHERE places.statefp10 = '${fips}' AND places.placefp10 = '${place_fips}')
            ), 3))
        FROM walmarts;"
done
