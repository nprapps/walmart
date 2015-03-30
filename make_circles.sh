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


psql walmart -c "DROP TABLE scales;"
psql walmart -c "CREATE TABLE scales (
);"

psql walmart -c "ALTER TABLE scales ADD COLUMN geom geometry(LINESTRING,4269);"

for fips in "${FIPS[@]}"
do
    place_fips=${PLACES["${fips}"]};

    psql walmart -c "
        INSERT INTO scales
        SELECT
            ST_MakeLine(
                ST_Transform(
                    ST_Translate(
                        ST_Transform(
                            ST_Centroid(places.wkb_geometry),
                            2163
                        ),
                        0,
                        0
                    ),
                    4269
                ),
                ST_Transform(
                    ST_Translate(
                        ST_Transform(
                            ST_Centroid(places.wkb_geometry),
                            2163
                        ),
                        1609.34,
                        0
                    ),
                    4269
                )
            )
        FROM places
        WHERE places.statefp10 = '${fips}' AND places.placefp10 = '${place_fips}';"
done
