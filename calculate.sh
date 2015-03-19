#!/bin/bash

echo "Generate geometry points off lat and long"
psql walmart -c "ALTER TABLE stores ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE stores ADD COLUMN geom geometry(POINT,4326);"
psql walmart -c "UPDATE stores SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql walmart -c "CREATE INDEX idx_stores_geom ON stores USING GIST(geom)"

echo "Calculate centroids of census blocks"
psql walmart -c "ALTER TABLE blocks ADD centroid_x double precision;"
psql walmart -c "ALTER TABLE blocks ADD centroid_y double precision;"
psql walmart -c "ALTER TABLE blocks ADD COLUMN centroid geometry(POINT,4326);"
psql walmart -c "UPDATE blocks SET centroid_x= ST_X(ST_Centroid(wkb_geometry));"
psql walmart -c "UPDATE blocks SET centroid_y= ST_Y(ST_Centroid(wkb_geometry));"
psql walmart -c "UPDATE blocks SET centroid = ST_SetSRID(ST_MakePoint(centroid_x,centroid_y),4326);"
psql walmart -c "CREATE INDEX idx_blocks_centroid ON blocks USING GIST(centroid)"

echo "Find nearest Walmart for every centroid"
psql walmart -c "CREATE OR REPLACE VIEW blocks_5km AS
    SELECT DISTINCT B.ogc_fid, B.pop10 as population, ST_Distance_Sphere(A.geom, B.centroid) as distance
    FROM stores AS A, blocks as B
    WHERE A.gid IN (
        SELECT X.gid
        FROM stores as X, blocks as Y
        WHERE X.state = 'HI' AND X.gid=A.gid
        ORDER BY ST_Distance_Sphere(X.geom, Y.centroid) ASC LIMIT 1
    ) AND B.pop10 > 0 AND ST_Distance_Sphere(A.geom, B.centroid) < 5000 ORDER BY B.ogc_fid LIMIT 1;"

psql walmart -c "COPY(select * from blocks_5km) to '`pwd`/build/blocks_in_range.csv' WITH CSV HEADER;"

echo "Find total number of people within x miles of a Walmart"
psql walmart -c "select (select sum(blocks_5km.population) from blocks_5km) / (select sum(blocks.pop10) from blocks);"
