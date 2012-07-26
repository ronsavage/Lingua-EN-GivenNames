#!/usr/bin/env perl

use strict;
use warnings;

use Lingua::EN::GivenNames::Database::Create;

# ----------------------------

Lingua::EN::GivenNames::Database::Create -> new(verbose => 2) -> create_all_tables;
