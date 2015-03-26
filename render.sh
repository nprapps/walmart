#!/bin/bash

source globals.sh

mkdir frames

for fips in "${FIPS[@]}"
do
    name=${NAMES["${fips}"]};
    place_fips=${PLACES["${fips}"]};
    latlng=${LATLNGS["${fips}"]};

    echo "* ${name}"

        for year in 2005 2010 2015
        do
            cp mapnik/map.xml .temp_map.xml
            sed -i '' "s/\$STATE_FIPS/${fips}/" .temp_map.xml
            sed -i '' "s/\$PLACE_FIPS/${place_fips}/" .temp_map.xml
            sed -i '' "s/\$YEAR/${year}/" .temp_map.xml

            ivframe --name ${name}_${year} -z 11 -w 1024 -t 1024 .temp_map.xml frames ${latlng}
        done
done
