#!/bin/bash

psql walmart -c "DROP TABLE circles;"
psql walmart -c "CREATE TABLE circles (
    store_number integer,
    year varchar,
    range integer
);"

psql walmart -c "ALTER TABLE circles ADD COLUMN geom geometry(POLYGON,4269);"

psql walmart -c "
    INSERT INTO circles
    SELECT
        store_number,
        year,
        1,
        ST_Transform(ST_Buffer(ST_Transform(geom, 2163), 1609.34), 4269)
    FROM walmarts;"

psql walmart -c "
    INSERT INTO circles
    SELECT
        store_number,
        year,
        2,
        ST_Transform(ST_Buffer(ST_Transform(geom, 2163), 3218.69), 4269)
    FROM walmarts;"
