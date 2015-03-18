#!/bin/bash

echo "Generate geometry points off lat and long"
psql walmart -c "ALTER TABLE stores ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE stores ADD COLUMN geom geometry(POINT,4326);"
psql walmart -c "UPDATE stores SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql walmart -c "CREATE INDEX idx_stores_geom ON stores USING GIST(geom)"

echo "Calculate centroids of census blocks"
psql walmart -c "ALTER TABLE chicago_blocks ADD centroid_x double precision;"
psql walmart -c "ALTER TABLE chicago_blocks ADD centroid_y double precision;"
psql walmart -c "ALTER TABLE chicago_blocks ADD COLUMN centroid geometry(POINT,4326);"
psql walmart -c "UPDATE chicago_blocks SET centroid_x= ST_X(ST_Centroid(wkb_geometry));"
psql walmart -c "UPDATE chicago_blocks SET centroid_y= ST_Y(ST_Centroid(wkb_geometry));"
psql walmart -c "UPDATE chicago_blocks SET centroid = ST_SetSRID(ST_MakePoint(centroid_x,centroid_y),4326);"
psql walmart -c "CREATE INDEX idx_blocks_centroid ON chicago_blocks USING GIST(centroid)"