#!/bin/bash

echo "Filter Walmarts to only ones with years"

psql walmart -c "DELETE FROM walmarts
    WHERE year NOT LIKE '____'
        OR year IS NULL;"

echo "Generate point geometries for walmarts"

psql walmart -c "ALTER TABLE walmarts ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE walmarts ADD COLUMN geom geometry(POINT,4269);"
psql walmart -c "UPDATE walmarts SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4269);"
psql walmart -c "CREATE INDEX idx_stores_geom ON walmarts USING GIST(geom)"

echo "Generate centroids for blocks"

psql walmart -c "ALTER TABLE blocks ADD COLUMN centroid geometry(POINT,4269);"
psql walmart -c "UPDATE blocks SET centroid = ST_SetSRID(ST_Centroid(wkb_geometry),4269);"

echo "Computing nearest walmarts for each block"

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
