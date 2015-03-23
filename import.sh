#!/bin/bash

echo "Create database"
dropdb --if-exists walmart
createdb walmart
psql walmart -c "CREATE EXTENSION postgis;"
psql walmart -c "CREATE EXTENSION postgis_topology"

# get walmart csv in the db
echo "Import walmarts.csv into the db"
psql walmart -c "CREATE TABLE stores (
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
psql walmart -c "COPY stores FROM '`pwd`/data/urban_walmarts_selected.csv' DELIMITER ',' CSV HEADER;"

echo "Import Census blocks"
ogr2ogr -update -append -f PostgreSQL PG:"dbname=walmart" shp/tabblock2010_13_pophu/tabblock2010_13_pophu.shp -nlt MULTIPOLYGON25D -nln blocks -progress
