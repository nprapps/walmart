# Walmarts

This script is a major work in progress and will require some manual readying. Sorry.

The `scrapers` folder is here for posterity, but isn't being used at all.

## Requirements

* Bash
* PostgreSQL
* PostGIS

You will need shapefiles for Census blocks in a state. The script currently works with Hawaii, but is easily alterable to work with any state.

To work with shapefiles for any state, change the following:

* In `import.sh`, update the path to the shapefiles in the ogr2ogr command at the bottom of the file.
* In `calculate.sh`, change the state in the CREATE VIEW command to the state you are currently looking at.

## Generating Postgres tables

```
./build.sh
```