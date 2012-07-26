#!/bin/bash

rm data/derivations.raw data/matches.log data/mismatches.log data/parse.log

perl -Ilib scripts/extract.derivations.pl -v 1 -s female -p $1
perl -Ilib scripts/parse.derivations.pl   -v 1

sort < data/matches.log > $$.log
mv $$.log data/matches.log

sort < data/mismatches.log > $$.log
mv $$.log data/mismatches.log
