#!/bin/bash

echo "Import Walmarts"

psql walmart -c "DROP TABLE walmarts;"
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

echo "Filter Walmarts to only ones with years"

psql walmart -c "DELETE FROM walmarts
    WHERE year NOT LIKE '____'
        OR year IS NULL;"
