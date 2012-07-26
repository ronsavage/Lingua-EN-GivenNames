#!/usr/bin/env perl
#
# Name:
#	export.as.csv.pl.

use open qw/:std :utf8/;
use strict;
use warnings;
use warnings qw/FATAL utf8/;

use Getopt::Long;

use Lingua::EN::GivenNames::Database::Export;

use Pod::Usage;

# -----------------------------------------------

my($option_parser) = Getopt::Long::Parser -> new();

my(%option);

if ($option_parser -> getoptions
(
	\%option,
	'help',
	'names_file=s',
	'verbose=s',
) )
{
	pod2usage(1) if ($option{'help'});

	exit Lingua::EN::GivenNames::Database::Export -> new(%option) -> as_csv;
}
else
{
	pod2usage(2);
}

__END__

=pod

=head1 NAME

export.as.csv.pl - Export the SQLite database as CSV

=head1 SYNOPSIS

export.as.html.pl [options]

	Options:
	-help
	-names_file $aFileName
	-verbose $integer

All switches can be reduced to a single letter.

Exit value: 0.

Default input: share/lingua.en.givennames.sqlite.

Default output: Screen.

=head1 OPTIONS

=over 4

=item o -names_file $aFileName

A CSV file name, to which given name data will be written.

Default: given.names.csv

=item o -help

Print help and exit.

=item o -verbose $integer

Print more or less progress reports. Details (more-or-less):

	0: Print nothing.
	1: Warnings, or anything I'm working on.
	2: The country table and specials table.
	3: The kinds of subcountries encountered. See comments in code re 'verbose > 2'.

Default: 0.

=back

=cut
