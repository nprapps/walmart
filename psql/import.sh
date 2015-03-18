#!/bin/bash

echo "Create database"
dropdb --if-exists walmart
createdb walmart
psql walmart -c "CREATE EXTENSION postgis;"
psql walmart -c "CREATE EXTENSION postgis_topology"
psql walmart -c "SELECT postgis_full_version()"

# get walmart csv in the db
echo "Import walmarts.csv into the db"
psql walmart -c "CREATE TABLE stores (
    store_number integer,
    store_type integer,
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
psql walmart -c "COPY stores FROM '`pwd`/walmart_03-05-15.csv' DELIMITER ',' CSV HEADER;"

echo "Generate geometry points off lat and long"
psql walmart -c "ALTER TABLE stores ADD COLUMN gid serial PRIMARY KEY;"
psql walmart -c "ALTER TABLE stores ADD COLUMN geom geometry(POINT,4326);"
psql walmart -c "UPDATE stores SET geom = ST_SetSRID(ST_MakePoint(longitude,latitude),4326);"
psql walmart -c "CREATE INDEX idx_stores_geom ON stores USING GIST(geom)"

echo "Import Illinois Census blocks"
ogr2ogr -update -append -f PostgreSQL PG:"dbname=walmart" shp/tl_2014_17_tabblock10/tl_2014_17_tabblock10.shp -nlt MULTIPOLYGON25D -nln chicago_blocks -progress