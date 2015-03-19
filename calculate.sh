#!/bin/bash

echo "Generate geometry points off lat and long"
psql walmart -c "ALTER TABLE stores ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE stores ADD COLUMN geom geometry(POINT,4326);"
psql walmart -c "UPDATE stores SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql walmart -c "CREATE INDEX idx_stores_geom ON stores USING GIST(geom)"

echo "Create table of each block's distance to a Walmart"

psql walmart -c "DROP TABLE unique_blocks_5km"
psql walmart -c "CREATE TABLE unique_blocks_5km AS
    SELECT
        Y.ogc_fid as block_id,
        Y.pop10 as population,
        min(ST_Distance_Sphere(X.geom, ST_Centroid(Y.wkb_geometry))) as distance
    FROM stores as X, blocks as Y
    WHERE X.state = 'DC'
    GROUP BY block_id, population;"