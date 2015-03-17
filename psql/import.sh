#!/bin/bash

echo "Create database"
dropdb --if-exists walmart
createdb walmart
psql walmart -c "CREATE EXTENSION postgis;"
psql walmart -c "CREATE EXTENSION postgis_topology"
psql walmart -c "SELECT postgis_full_version()"

# get walmart csv in the db
echo "Import walmarts.csv into the db"
psql walmart -c "CREATE TABLE data (
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
    latitude decimal,
    longitude decimal
);"
psql walmart -c "COPY data FROM '`pwd`/walmart_03-05-15.csv' DELIMITER ',' CSV HEADER;"

