#!/bin/bash

echo "Filter Walmarts to only ones with years"
psql walmart -c "DROP TABLE urban_walmarts;"
psql walmart -c "CREATE TABLE urban_walmarts AS
    SELECT * from stores
    WHERE year LIKE '____';"

echo "Generate geometry points off lat and long"
psql walmart -c "ALTER TABLE urban_walmarts ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE urban_walmarts ADD COLUMN geom geometry(POINT,4269);"
psql walmart -c "UPDATE urban_walmarts SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4269);"
psql walmart -c "CREATE INDEX idx_stores_geom ON urban_walmarts USING GIST(geom)"

psql walmart -c "ALTER TABLE blocks ADD COLUMN centroid geometry(POINT,4269);"
psql walmart -c "UPDATE blocks SET centroid = ST_SetSRID(ST_Centroid(wkb_geometry),4269);"

echo "Create table of each block's distance to a Walmart"

psql walmart -c "ALTER TABLE blocks ADD COLUMN distance integer;"
psql walmart -c "UPDATE blocks
    SET distance = (
        SELECT min(ST_Distance_Sphere(urban_walmarts.geom, blocks.centroid))
        FROM urban_walmarts
    )"

echo "Computing nearest walmarts for each block"

psql walmart -c "DROP TABLE nearest;"
psql walmart -c "CREATE TABLE nearest AS
    SELECT DISTINCT ON (blocks.ogc_fid)
        blocks.ogc_fid,
        urban_walmarts.store_number,
        min(ST_Distance_Sphere(urban_walmarts.geom, blocks.centroid)) as distance
    FROM
        blocks,
        urban_walmarts
    GROUP BY
        blocks.ogc_fid,
        urban_walmarts.store_number
    ORDER BY
        blocks.ogc_fid,
        distance;"
