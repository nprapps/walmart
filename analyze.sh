#!/bin/bash

source globals.sh

echo "Compute population within 5 miles of a Walmart"

for fips in "${FIPS[@]}"
do
    place_fips=${PLACES["${fips}"]};

    # Compute 5 miles in meters
    meters=`echo "5 * 1609.344" | bc`;

    echo "${fips}, ${place_fips}"

    psql walmart -c "
        SELECT
            sum(blocks.pop10)
        FROM
            blocks,
            nearest,
            walmarts,
            atlanta_city_limits
        WHERE
            -- Filter to state blocks first for performance
            blocks.statefp10 = '${fips}' AND
            ST_Within(blocks.centroid, (SELECT wkb_geometry FROM places WHERE statefp10 = '${fips}' AND placefp10 = '${place_fips}')) AND
            blocks.ogc_fid = nearest.ogc_fid AND
            nearest.store_number = walmarts.store_number AND
            nearest.distance < ${meters};"
done

# walmarts.year::integer <= 2005 AND
