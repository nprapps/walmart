#!/bin/bash

echo "Generate centroids for blocks"

psql walmart -c "ALTER TABLE blocks ADD COLUMN centroid geometry(POINT,4269);"
psql walmart -c "UPDATE blocks SET centroid = ST_SetSRID(ST_Centroid(wkb_geometry),4269);"

echo "Computing nearest walmarts for each block (this part is slow)"

psql walmart -c "DROP TABLE nearest;"
psql walmart -c "CREATE TABLE nearest AS
    SELECT DISTINCT ON (blocks.ogc_fid)
        blocks.ogc_fid,
        walmarts.store_number,
        min(ST_Distance_Sphere(walmarts.geom, blocks.centroid)) as distance
    FROM
        blocks,
        walmarts
    GROUP BY
        blocks.ogc_fid,
        walmarts.store_number
    ORDER BY
        blocks.ogc_fid,
        distance;"
