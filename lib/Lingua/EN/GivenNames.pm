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
	$$arg{config_file} ||= '.ht.lingua.en.givennames.conf'; # Caller can set.
	$$arg{data_dir}    = 'data';
	$$arg{sex}         ||= ''; # Caller can set.
	$$arg{sqlite_file} ||= 'lingua.en.givennames.sqlite';  # Caller can set.
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

Lingua::EN::GivenNames - An SQLite database of derivations of English given names

=head1 Synopsis

www.20000-names.com I<has been scraped>. You do not need to run the script which downloads pages from there.

Just use the SQLite database shipped with this module, as discussed next, or one of the export scripts.

The database is on-line at: L<http://savage.net.au/Perl-modules/html/Lingua/EN/GivenNames/given.names.html>.
That page was created with the jQuery option to scripts/export.as.html.pl set to 1.

=head2 Basic Usage

This is the simplest way to access the data.

	use Lingua::EN::GivenNames::Database;

	my($database) = Lingua::EN::GivenNames::Database -> new;

	# $names is an arrayref of hashrefs.

	my($names) = $database -> read_names_table;

Each element in @$names contains data for 1 record in the database, and has these keys
(in alphabetical order):

	{
		derivation => The derivation,
		fc_name    => The case-folded name,
		form       => The form,
		id         => The primary key of this record,
		kind       => The kind,
		meaning    => The meaning,
		name       => The name,
		original   => The original (name),
		rating     => The rating (relability indicator),
		sex        => The sex,
		source     => The source (language or name),
	}

See L</FAQ> entries for details.

=head2 Scripts which output to a file

All scripts respond to the -h option.

Some examples, with output files that happen to be the defaults:

	shell>perl scripts/export.as.csv.pl  -cvs_file      given.names.csv
	shell>perl scripts/export.as.html.pl -web_page_file given.names.html

=head1 Description

C<Lingua::EN::GivenNames> is a pure Perl module.

It is used to download various Englsh given names-related pages from 20000-names.com, and to then
import data scraped from those pages into an SQLite database.

The pages have already been downloaded, so that phase only needs to be run when pages are updated.
Likewise, the data has been imported.

This means you would normally only ever use the database in read-only mode, as per the L</Synopsis>.

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

Default: .ht.lingua.en.givennames.conf.

=item o sqlite_file => $file_name

The name of the SQLite database of country and subcountry data.

The code prefixes this name with the directory returned by L<File::ShareDir/dist_dir()>.

Default: lingua.en.givennames.sqlite.

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

=head2 What does L<Lingua::EN::GivenNames::Database>'s read_names_table() return?

It returns an arrayref of hashrefs.

Each element in the arrayref contains data for 1 record built from the names table, and has these keys
(in alphabetical order):

	{
		derivation => The derivation,
		fc_name    => The case-folded name,
		form       => The form,
		id         => The primary key of this record,
		kind       => The kind,
		meaning    => The meaning,
		name       => The name,
		original   => The original (name),
		rating     => The rating (relability indicator),
		sex        => The sex,
		source     => The source (language or name),
	}

Details:

=over 4

=item o derivation

This is the name field from the derivations table.

=item o fc_name

This is the case-folded version of the name field (below).
It comes from the name field of the names table.

=item o form

This is the name field from the forms table.

=item o id

This is the primary key in the names table.

=item o kind

This is the name field from the kinds table.

=item o meaning

This is the name field from the meanings table.

=item o name

This is, finally, the name itself.

=item o original

This is the name field from the originals table.

=item o rating

This is the name field from the ratings table.

=item o sex

This is the name field from the sexes table.

=item o source

This is the name field from the sources table.

=back

=head2 Are the input web pages difficult to process?

Yes! Some pages contain names in various character encodings, making the derivation analysis very
difficult.

Examples of the many, many things to watch out for are:

=over 4

=item o data/female_english_names.htm line 4913

=item o data/female_english_names_05.htm line 3284

=item o The hex char \xC2

This appears all over the place.

=item o Nested web pages

The pages contain the names in a table of 1 row and 1 column, within which is a long list
of the <li> entries I parse.

But elsewhere on the pages, entire web pages have been jammed into table cells. Thanx FrontPage!

=back

=head2 Where is the database?

It is shipped in share/lingua.en.givennames.sqlite.

It is installed into the distro's shared dir, as returned by L<File::ShareDir/dist_dir()>.
On my machine that's:

/home/ron/perl5/perlbrew/perls/perl-5.14.2/lib/site_perl/5.14.2/auto/share/dist/Lingua-EN-GivenNames/lingua.en.givennames.sqlite.

=head2 Where is the config file?

It is shipped in share/.ht.lingua.en.givennames.conf.

It is installed into the distro's shared dir, along with the database.

=head2 What is the database schema?

The table names are: forms, kinds, meanings, names, originals, ratings, sexes and sources,
with names being the main table.

=head2 What do I do if I find a mistake in the data?

What data? What mistake? How do you know it's wrong?

Also, you must decide what exactly you were expecting the data to be.

Firstly, report your claim to the webmaster at L<20000-names.com>.

Note: The input data is partially free-form, as per the original web pages, and commentary
as used on those pages I<is impossible to parse perfectly with regexps>.

So, perhaps the solution lies in making the regexps in L<Lingua::EN::GivenNames::Database::Import> smarter.

Another possibility is to pre-process one or both of the input files data/derivations.raw and
data/derivations.csv before they are processed. The next question discusses how to intervene in the
data flow.

=head2 How do the scripts and modules interact to produce the data?

Recall from above that the web site L<20000-names.com> I<has been scraped>. The output files from that
step are in data/*.htm.

The database tables are created with:

	scripts/drop.tables.pl
	scripts/create.tables.pl

Then the data is processed with:

	Input files: data/*.htm
	Reader:      scripts/extract.derivations.pl
	Output file: data/derivations.raw
	Reader:      scripts/parse.derivations.pl
	Output file: data/derivations.csv
	Reader:      scripts/import.derivations.pl
	Output file: share/lingua.en.givennames.sqlite (when $ENV{AUTHOR_TESTING} == 1)
	Reader:      scripts/export.pl
	Output file: data/given.names.html

Scripts (in alphabetical order):

=over 4

=item o scripts/create.tables.pl

Creates all the database tables. Remember to run drop.tables.pl first if the tables already exist.

=item o scripts/drop.tables.pl

Drops all the database tables. Then run create.tables.pl immediately afterwards.

=item o scripts/export.pl

This script obviously reads the database and outputs the expected data. It uses
L<Lingua::EN::GivenNames::Database::Export>, and command line options -csv_file or -web_page_file.

=item o scripts/extract.derivations.pl

This script is run once each for 20 pages of female names and once each for 17 pages of male names.
It uses L<Lingua::EN::GivenNames::Database::Import>.

=item o scripts/extract.parse.sh

Run scripts/extract.derivations.pl and then scripts/parse.derivations.pl on one page for one sex.
This script is used only by the author while developing the module.

=item o scripts/get.name.pages.pl

This script is run once to get 20 pages of female names and once to get 17 pages of male names.
It uses L<Lingua::EN::GivenNames::Database::Download>.

=item o scripts/import.derivations.pl

This scripts actually writes the database tables. It uses L<Lingua::EN::GivenNames::Database::Import>.

=item o scripts/import.sh

That sequence of commands (above) is performed by scripts/import.sh.

=item o scripts/parse.derivations.pl

Besides outputting data/derivations.csv, this script also outputs data/mismatches.log and
data/parse.log. It uses L<Lingua::EN::GivenNames::Database::Import>.

Also, this script uses data/unparsable.txt to skip some names. Further, it currently skips names which
are not all ASCII characters.

=item o scripts/plot.schema.sh

Should output a *.png file of the database's schema, but it doesn't.

=item o scripts/report.statistics.pl

Prints these database statistics:

	Table            Records
	derivations         3062
	forms                 15
	kinds                 52
	meanings            1356
	names               3967
	originals           2393
	ratings                5
	sexes                  2
	sources               56

=item o scripts/test.pattern.pl

This is code I use to test new regexps before putting them into production in sub parse_derivations()
in L<Lingua::EN::GivenNames::Database::Import>.

=back

=head2 What is $ENV{AUTHOR_TESTING} used for?

When this env var is 1, scripts output to share/*.sqlite within the distro's dir. That's how I populate the
database tables. After installation, the database is elsewhere, and read-only, so you don't want the scripts
writing to that copy anyway.

After end-user installation, L<File::ShareDir> is used to find the installed version of *.sqlite.

=head2 Why don't you use Perl6::Slurp to read files?

Because I found it (V 0.051000) did not respect the 'raw' file encoding option I specified.

=head1 Non-English names

The web site L<20000-names.com> has names in various other languages, for those wishing the adapt
this code to deal with those cases.

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
