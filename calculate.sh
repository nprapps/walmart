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

psql walmart -c "DROP TABLE unique_blocks_5km"
psql walmart -c "CREATE TABLE unique_blocks_5km AS
    SELECT
        Y.ogc_fid as block_id,
        Y.pop10 as population,
        min(ST_Distance_Sphere(X.geom, Y.centroid)) as distance
    FROM urban_walmarts as X, blocks as Y
    GROUP BY block_id, population;"
