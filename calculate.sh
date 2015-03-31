#!/bin/bash

source globals.sh

echo "Generate centroids for blocks"

#psql walmart -c "ALTER TABLE blocks ADD COLUMN centroid geometry(POINT,4269);"
#psql walmart -c "UPDATE blocks SET centroid = ST_SetSRID(ST_Centroid(wkb_geometry),4269);"

echo "Computing nearest walmarts for each block (this part is slow)"

for year in "${YEARS[@]}"
do
    echo "  * ${year}"

    psql walmart -c "ALTER TABLE blocks ADD COLUMN nearest${year} numeric;"

    psql walmart -c "
        UPDATE blocks
        SET nearest${year} = (
            SELECT min(ST_Distance_Sphere(walmarts.geom, blocks.centroid))
            FROM walmarts
            WHERE walmarts.year::INTEGER <= ${year});
    "
done
