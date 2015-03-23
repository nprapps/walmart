#!/bin/bash

echo "Create database"

dropdb --if-exists walmart
createdb walmart
psql walmart -c "CREATE EXTENSION postgis;"
psql walmart -c "CREATE EXTENSION postgis_topology"

echo "Import Walmarts"

psql walmart -c "CREATE TABLE walmarts (
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

psql walmart -c "COPY walmarts FROM '`pwd`/data/urban_walmarts_dates.csv' DELIMITER ',' CSV HEADER;"

echo "Import city outlines"

ogr2ogr -f PostgreSQL PG:"dbname=walmart" shp/atlanta_city_limits/ATL_POLITIC_ATLANTA_CITY_LIMITS.shp -nlt MULTIPOLYGON -nln atlanta_city_limits -progress -lco PRECISION=NO

echo "Importing Census blocks"

ogr2ogr -f PostgreSQL PG:"dbname=walmart" shp/georgia_blocks/tabblock2010_13_pophu.shp -nlt MULTIPOLYGON -nln blocks -progress
