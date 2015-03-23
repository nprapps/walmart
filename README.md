# Walmarts

This script is a major work in progress and will require some manual readying. Sorry.

The `scrapers` folder is here for posterity, but isn't being used at all.

## Requirements

* Bash
* PostgreSQL
* PostGIS

## Getting shapefiles

```
curl -O http://www2.census.gov/geo/tiger/TIGER2010BLKPOPHU/tabblock2010_13_pophu.zip
unzip tabblock2010_13_pophu.zip -d shp/georgia_blocks
curl -O http://gis.atlantaga.gov/apps/gislayers/download/layers/ATL_POLITIC_ATLANTA_CITY_LIMITS.zip
unzip ATL_POLITIC_ATLANTA_CITY_LIMITS.zip -d shp/atlanta_city_limits
```

To work with shapefiles for any state, change the following:

* In `import.sh`, update the path to the shapefiles in the ogr2ogr command at the bottom of the file.
* In `calculate.sh`, change the state in the CREATE VIEW command to the state you are currently looking at.

## Generating Postgres tables

```
./build.sh
```
