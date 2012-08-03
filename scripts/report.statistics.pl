#!/usr/bin/env perl

use strict;
use warnings;

use Lingua::EN::GivenNames::Database;

# -----------------------------------------------

my($data) = Lingua::EN::GivenNames::Database -> new-> get_tables;
my($format) = "%-15s  %7s\n";

print sprintf $format, 'Table', 'Records';

my($records);

for my $table_name (sort keys %$data)
{
	$records = $$data{$table_name};

	print sprintf $format, $table_name, scalar keys %$records;
}
