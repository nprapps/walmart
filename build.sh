#!/bin/bash

echo "DOWNLOADING DATA"
echo "----------------"
./download.sh

echo "SETUP DATABASE"
echo "--------------"
createdb walmart
psql walmart -c "CREATE EXTENSION postgis;"
psql walmart -c "CREATE EXTENSION postgis_topology"

echo "IMPORT WALMARTS"
echo "---------------"
./import_stores.sh

echo "IMPORT SHAPES"
echo "-------------"
./import_shapes.sh

echo "MAKE CALCULATIONS"
echo "-----------------"
./calculate.sh
./analyze.sh
