#!/bin/bash

dbigraph.pl --dsn=dbi:SQLite:dbname=share/lingua.en.givennames.sqlite --as=png > ./data/given.names.schema.png

echo Wrote ./data/given.names.schema.png
