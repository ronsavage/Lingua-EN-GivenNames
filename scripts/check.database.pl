#!/usr/bin/env perl

use feature qw/say unicode_strings/;
use open qw(:std :utf8);
use strict;
use warnings;
use warnings qw(FATAL utf8);

use DBI;

# -----------------------------------------------

my($table) = shift || 'sexes';
my($dbh)   = DBI -> connect('dbi:SQLite:dbname=share/lingua.en.givennames.sqlite', '', '');
my($sth)   = $dbh -> prepare("select * from $table");

$sth -> execute;

my($data) = $sth -> fetchall_hashref('id');

for my $id (sort keys %$data)
{
	say join(', ', map{"$_ => $$data{$id}{$_}"} sort keys %{$$data{$id} });
}
