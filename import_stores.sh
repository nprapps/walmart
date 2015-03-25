#!/bin/bash

echo "Import Walmarts"

psql walmart -c "DROP TABLE all_walmarts;"
psql walmart -c "CREATE TABLE all_walmarts (
    store_number integer,
    store_type integer,
    region varchar,
    year varchar,
    display_name varchar,
    address varchar,
    city varchar,
    state varchar,
    zip_code integer,
    country varchar,
    phone_number varchar,
    store_hours varchar,
    pharmacy_phone varchar,
    pharmacy_hours varchar,
    services varchar,
    vision_phone varchar,
    photo_phone varchar,
    tire_phone varchar,
    latitude float,
    longitude float
);"

psql walmart -c "COPY all_walmarts FROM '`pwd`/data/urban_walmarts_dates.csv' DELIMITER ',' CSV HEADER;"

echo "Generate point geometries for walmarts"

psql walmart -c "ALTER TABLE all_walmarts ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE all_walmarts ADD COLUMN geom geometry(POINT,4269);"
psql walmart -c "UPDATE all_walmarts SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4269);"
psql walmart -c "CREATE INDEX idx_stores_geom ON all_walmarts USING GIST(geom)"

echo "Filter Walmarts to only ones with years"

psql walmart -c "DROP TABLE walmarts;"
psql walmart -c "CREATE TABLE walmarts AS
    SELECT * FROM all_walmarts
    WHERE year LIKE '____';"
