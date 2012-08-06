#!/usr/bin/env perl
#
# Name:
#	export.pl.

use strict;
use warnings;

use Getopt::Long;

use Lingua::EN::GivenNames::Database::Export;

use Pod::Usage;

# -----------------------------------------------

my($option_parser) = Getopt::Long::Parser -> new();

my(%option);

if ($option_parser -> getoptions
(
	\%option,
	'csv_file=s',
	'help',
	'jquery=i',
	'verbose:i',
	'web_page_file=s',
) )
{
	pod2usage(1) if ($option{'help'});

	exit Lingua::EN::GivenNames::Database::Export -> new(%option) -> export;
}
else
{
	pod2usage(2);
}

__END__

=pod

=head1 NAME

export.pl - Export the SQLite database as HTML

=head1 SYNOPSIS

export.pl [options]

	Options:
	-csv_file $aFileName
	-help
	-jquery $Boolean
	-verbose $integer
	-web_page_file $aFileName

All switches can be reduced to a single letter.

Exit value: 0.

Default input: share/lingua.en.givennames.sqlite.

Default output: Screen.

=head1 OPTIONS

=over 4

=item o -csv_file $aFileName

A CSV file name, to which given name data will be written.

You must specify a file with either -c or -w.

Default: ''.

=item o -help

Print help and exit.

=item o -jquery $Boolean

If set to 1, output jQuery-friendy HTML table stuff embedding the value of jquery_url from the config file.

Default: 0.

=item o -verbose $integer

Print more or less progress reports. Details (more-or-less):

	0: Print nothing. The default if $integer is not supplied.
	1: Warnings, or anything I'm working on.
	2: The country table and specials table.
	3: The kinds of subcountries encountered. See comments in code re 'verbose > 2'.

Default: 0.

=item o -web_page_file $aFileName

A HTML file name, to which given name data is to be output.

You must specify a file with either -c or -w.

Default: ''.

=back

=cut
