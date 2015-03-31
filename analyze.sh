#!/bin/bash

source globals.sh

echo "Compute population within 1 mile of a Walmart"

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};
    place_fips=${PLACES["${fips}"]};
    pop=${POPS["${fips}"]};

    # Compute 1 miles in meters
    meters=`echo "1 * 1609.344" | bc`;

    echo "* ${name}"

        for year in "${YEARS[@]}"
        do
            echo "  * ${year}"

            psql walmart -c "
                SELECT
                    sum(blocks.pop10) as pop_near_walmart,
                    ${pop} as pop_total,
                    round(sum(blocks.pop10) / ${pop} * 100, 2) as pct
                FROM
                    blocks,
                    places
                WHERE
                    -- Filter to state blocks first for performance
                    blocks.statefp10 = '${fips}' AND
                    places.statefp10 = '${fips}' AND
                    places.placefp10 = '${place_fips}' AND
                    ST_Within(blocks.centroid, places.wkb_geometry) AND
                    blocks.nearest${year} < ${meters};"
        done
done
