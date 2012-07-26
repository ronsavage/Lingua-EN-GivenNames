package Lingua::EN::GivenNames;

use 5.008;
use strict;
use warnings;

use Config::Tiny;

use File::ShareDir;
use File::Spec;

use Hash::FieldHash ':all';

fieldhash my %config      => 'config';
fieldhash my %config_file => 'config_file';
fieldhash my %data_dir    => 'data_dir';
fieldhash my %sex         => 'sex';
fieldhash my %share_dir   => 'share_dir';
fieldhash my %sqlite_file => 'sqlite_file';
fieldhash my %verbose     => 'verbose';

our $VERSION = '1.00';

# -----------------------------------------------

sub _init
{
	my($self, $arg)    = @_;
	$$arg{config_file} ||= '.htlocale.givennames.en.conf'; # Caller can set.
	$$arg{data_dir}    = 'data';
	$$arg{sex}         ||= ''; # Caller can set.
	$$arg{sqlite_file} ||= 'locale.givennames.en.sqlite';  # Caller can set.
	$$arg{verbose}     ||= 0; # Caller can set.
	$self              = from_hash($self, $arg);
	(my $package       = __PACKAGE__) =~ s/::/-/g;
	my($dir_name)      = $ENV{AUTHOR_TESTING} ? 'share' : File::ShareDir::dist_dir($package);

	$self -> config_file(File::Spec -> catfile($dir_name, $self -> config_file) );
	$self -> config(Config::Tiny -> read($self -> config_file) );
	$self -> sqlite_file(File::Spec -> catfile($dir_name, $self -> sqlite_file) );

	binmode STDOUT;

	$self -> log(debug => 'Config file: ' . $self -> config_file);
	$self -> log(debug => 'SQLite file: ' . $self -> sqlite_file);

	return $self;

} # End of _init.

# -----------------------------------------------

sub log
{
	my($self, $level, $s) = @_;
	$level ||= 'debug';
	$s     ||= '';

	print "$level: $s. \n" if ($self -> verbose);

}	# End of log.

# -----------------------------------------------

sub new
{
	my($class, %arg) = @_;
	my($self)        = bless {}, $class;
	$self            = $self -> _init(\%arg);

	return $self;

}	# End of new.

# -----------------------------------------------

1;

=pod

=head1 NAME

Lingua::EN::GivenNames - SQLite database of derivations of given names

=head1 Synopsis

www.20000-names.com I<has been scraped>. You do not need to run the scripts which download pages from there.

Just use the SQLite database shipped with this module, as discussed next.

=head2 Methods which return hashrefs

	use Lingua::EN::GivenNames::Database;

	my($database) = Lingua::EN::GivenNames::Database -> new;
	my($names)    = $database -> read_names_table; # $names is a hashref.
	...

Each key in %$names points to a hashref of all columns for the given key.

...

=head3 Warnings

# 1: These hashrefs use the table's primary key as the hashref's key. In the case of the I<names>
table, the primary key is the name's id. See L</What is the database schema?> for details.

=head2 Scripts which output to a file

All scripts respond to the -h option.

Some examples:

	shell>perl scripts/export.as.csv.pl -c given.names.csv
	shell>perl scripts/export.as.html.pl -w given.names.html

This file is on-line at: L<http://savage.net.au/Perl-modules/html/Locale/GivenNames/en/given.names.html>.

	shell>perl scripts/report.statistics.pl

	Output statistics:
	names_in_db => 249.

=head1 Description

C<Lingua::EN::GivenNames> is a pure Perl module.

It is used to download various given names-related pages from 20000-names.com, and to then import data
(scraped from those pages) into an SQLite database.

The pages have already been downloaded, so that phase only needs to be run when pages are updated.

Likewise, the data has been imported.

This means you would normally only ever use the database in read-only mode.

Scripts shipped with this distro are:

=over 4

=item o scripts/get.name.pages.pl

1: Downloads the sets of male and female names from 20000-names.com.

Output: data/*.htm.

=item o scripts/extract.derivations.pl

Extracts the individual name derivations from the downloaded web pages.

inputs: data/*.htm.

Output: data/derivations.raw.

=item o scripts/parse.derivations.pl

Input: data/derivations.raw.

Output: data/matches.log, data/mismatches.log and data/parse.log.

=item o scripts/import.derivations.pl

Input: data/matches.log.

Output: share/locale.givennames.en.sqlite.

Note: When the distro is installed, this SQLite file is installed too.
See L</Where is the database?> for details.

=item o scripts/export.as.csv.pl -g data/given.names.csv

Exports the name data as CSV.

Input: share/locale.givennames.en.sqlite.

Output: data/names.csv.

=item o scripts/export.as.html -w data/given.names.html

Input: share/locale.givennames.en.sqlite.

Output: data/given.names.html.

On-line: L<http://savage.net.au/Perl-modules/html/Locale/GivenNames/en/given.names.html>.

=back

=head1 Constructor and initialization

new(...) returns an object of type C<Lingua::EN::GivenNames>.

This is the class's contructor.

Usage: C<< Lingua::EN::GivenNames -> new() >>.

This method takes a hash of options.

Call C<new()> as C<< new(option_1 => value_1, option_2 => value_2, ...) >>.

Available options (these are also methods):

=over 4

=item o config_file => $file_name

The name of the file containing config info, such as I<css_url> and I<template_path>.
These are used by L<Lingua::EN::GivenNames::Database::Export/as_html()>.

The code prefixes this name with the directory returned by L<File::ShareDir/dist_dir()>.

Default: .htlocale.givennames.en.conf.

=item o sqlite_file => $file_name

The name of the SQLite database of country and subcountry data.

The code prefixes this name with the directory returned by L<File::ShareDir/dist_dir()>.

Default: locale.givennames.en.sqlite.

=item o verbose => $integer

Print more or less information.

Default: 0 (print nothing).

=back

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

Install Lingua::EN::GivenNames as you would for any C<Perl> module:

Run:

	cpanm Lingua::EN::GivenNames

or run:

	sudo cpan Lingua::EN::GivenNames

or unpack the distro, and then run:

	perl Makefile.PL
	make (or dmake)
	make test
	make install

See L<http://savage.net.au/Perl-modules.html> for details.

See L<http://savage.net.au/Perl-modules/html/installing-a-module.html> for
help on unpacking and installing.

=head1 Methods

=head2 config_file($file_name)

Get or set the name of the config file.

The code prefixes this name with the directory returned by L<File::ShareDir/dist_dir()>.

Also, I<config_file> is an option to L</new()>.

=head2 log($level => $s)

Print $s at log level $level, if ($self -> verbose);

Since $self -> verbose defaults to 0, nothing is printed by default.

=head2 new()

See L</Constructor and initialization>.

=head2 sqlite_file($file_name)

Get or set the name of the database file.

The code prefixes this name with the directory returned by L<File::ShareDir/dist_dir()>.

Also, I<sqlite_file> is an option to L</new()>.

=head2 verbose($integer)

Get or set the verbosity level.

Also, I<verbose> is an option to L</new()>.

=head1 FAQ

=head2 Where is the database?

It is shipped in share/locale.givennames.en.sqlite.

It is installed into the distro's shared dir, as returned by L<File::ShareDir/dist_dir()>.
On my machine that's:

/home/ron/perl5/perlbrew/perls/perl-5.14.2/lib/site_perl/5.14.2/auto/share/dist/Locale-GivenNames-en/locale.givennames.en.sqlite.

=head2 What is the database schema?

The table names are: forms, kinds, meanings, names, originals, sexes, sources, which names being the main table.

=head2 What do I do if I find a mistake in the data?

What data? What mistake? How do you know it's wrong?

Also, you must decide what exactly you were expecting the data to be.

The input data is partially free-form, as per the original web pages, and commentry like that I<is impossible to
parse perfectly with regexps>. So, perhaps the solution lies in making the regexps in
L<Lingua::EN::GivenNames::Database::Import> smarter. Patches welcome.

=head2 What is $ENV{AUTHOR_TESTING} used for?

When this env var is 1, scripts output to share/*.sqlite within the distro's dir. That's how I populate the
database tables. After installation, the database is elsewhere, and read-only, so you don't want the scripts
writing to that copy anyway.

At run-time, L<File::ShareDir> is used to find the installed version of *.sqlite.

=head1 References

=head1 Support

Email the author, or log a bug on RT:

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Lingua::EN::GivenNames>.

=head1 Author

C<Lingua::EN::GivenNames> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2012.

Home page: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2012 Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html


=cut
