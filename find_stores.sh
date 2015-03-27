#!/bin/bash

source globals.sh

psql walmart -c "DROP TABLE regions;"
psql walmart -c "CREATE TABLE regions (
    name varchar,
    statefp10 varchar,
    placefp10 varchar
);"
psql walmart -c "ALTER TABLE regions ADD COLUMN geom geometry(POLYGON,4269);"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};
    place_fips=${PLACES["${fips}"]};
    pop=${POPS["${fips}"]};

    # Compute 1 miles in meters
    meters=`echo "15 * 1609.344" | bc`;

    echo "* ${name}"

    psql walmart -c "
        INSERT INTO regions
        SELECT
            '${name}',
            '${fips}',
            '${place_fips}',
            ST_Transform(ST_Buffer(
                ST_Transform(ST_Centroid(
                    places.wkb_geometry
                ), 2163),
                (ST_MaxDistance(
                    ST_Envelope(ST_Transform(places.wkb_geometry, 2163)),
                    ST_Envelope(ST_Transform(places.wkb_geometry, 2163))
                ) * 0.5) * 1.5,
                32
            ), 4269)
        FROM
            places
        WHERE
            places.statefp10 = '${fips}' AND
            places.placefp10 = '${place_fips}';
    "
done

echo "Exporting list of walmarts in bounding regions"

psql walmart -c "
    COPY
    (SELECT
        store_number,
        store_type,
        region,
        year,
        address,
        city,
        state
    FROM
        all_walmarts,
        regions
    WHERE
        ST_Contains(
            regions.geom,
            all_walmarts.geom
        )
    )
    TO '`pwd`/data/search.csv' WITH CSV HEADER;
"
