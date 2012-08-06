#!/usr/bin/env perl

use feature qw/say unicode_strings/;
use open qw(:std :utf8);
use strict;
use warnings;
use warnings qw(FATAL utf8);

use Lingua::EN::GivenNames::Database;

# -----------------------------------------------

my($data) = Lingua::EN::GivenNames::Database -> new-> get_tables;
my($format) = "%-15s  %7s";

say sprintf $format, 'Table', 'Records';

my($records);

for my $table_name (sort keys %$data)
{
	$records = $$data{$table_name};

	say sprintf $format, $table_name, scalar keys %$records;
}
