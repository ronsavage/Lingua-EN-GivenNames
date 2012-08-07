package Lingua::EN::GivenNames::Database;

use feature qw/say unicode_strings/;
use open qw(:std :utf8);
use parent 'Lingua::EN::GivenNames';
use strict;
use warnings;
use warnings qw(FATAL utf8);

use DBI;

use DBIx::Admin::CreateTable;
use DBIx::Table2Hash;

use File::Slurp; # For read_dir().

use Hash::FieldHash ':all';

use Lingua::EN::StopWordList;

use List::Compare;

fieldhash my %attributes  => 'attributes';
fieldhash my %creator     => 'creator';
fieldhash my %dbh         => 'dbh';
fieldhash my %dsn         => 'dsn';
fieldhash my %engine      => 'engine';
fieldhash my %name        => 'name';
fieldhash my %page_counts => 'page_counts';
fieldhash my %password    => 'password';
fieldhash my %time_option => 'time_option';
fieldhash my %username    => 'username';

our $VERSION = '1.00';

# ----------------------------------------------

sub get_name_count
{
	my($self) = @_;

	return ($self -> dbh -> selectrow_array('select count(*) from names') )[0];

} # End of get_name_count.

# -----------------------------------------------

sub get_tables
{
	my($self) = @_;

	my(%data);

	for my $table_name (values %{$self -> table_names})
	{
		$data{$table_name} = DBIx::Table2Hash -> new
		(
			dbh        => $self -> dbh,
			key_column => 'id',
			table_name => $table_name,
		) -> select_hashref;
	}

	return \%data;

} # End of get_tables.

# -----------------------------------------------

sub _init
{
	my($self, $arg)    = @_;
	$$arg{attributes}  ||= {AutoCommit => 1, RaiseError => 1, sqlite_unicode => 1}; # Caller can set.
	$$arg{creator}     = '';
	$$arg{dbh}         = '';
	$$arg{dsn}         = '';
	$$arg{engine}      = '';
	$$arg{name}        ||= ''; # Caller can set.
	$$arg{page_counts} = {female => 20, male => 17};
	$$arg{password}    = '';
	$$arg{time_option} = '';
	$$arg{username}    = '';
	$self              = $self -> SUPER::_init($arg);

	$self -> dsn('dbi:SQLite:dbname=' . $self -> sqlite_file);
	$self -> dbh(DBI -> connect($self -> dsn, $self -> username, $self -> password, $self -> attributes) ) || die $DBI::errstr;
	$self -> dbh -> do('PRAGMA foreign_keys = ON') if ($self -> dsn =~ /SQLite/i);

	$self -> creator
		(
		 DBIx::Admin::CreateTable -> new
		 (
		  dbh     => $self -> dbh,
		  verbose => 0,
		 )
		);

	$self -> engine
		(
		 $self -> creator -> db_vendor =~ /(?:Mysql)/i ? 'engine=innodb' : ''
		);

	$self -> time_option
		(
		 $self -> creator -> db_vendor =~ /(?:MySQL|Postgres)/i ? '(0) without time zone' : ''
		);

	return $self;

} # End of _init.

# -----------------------------------------------

sub new
{
	my($class, %arg) = @_;
	my($self)        = bless {}, $class;
	$self            = $self -> _init(\%arg);

	return $self;

}	# End of new.

# ----------------------------------------------

sub read_names_table
{
	my($self) = @_;
	my($data) = $self -> get_tables;

	my($entry);
	my(@name);

	for my $id (keys %{$$data{names} })
	{
		$entry = $$data{names}{$id};

		push @name,
		{
			derivation => $$data{derivations}{$$entry{derivation_id} }{name},
			fc_name    => $$entry{fc_name},
			form       => $$data{forms}{$$entry{form_id} }{name},
			id         => $id,
			kind       => $$data{kinds}{$$entry{kind_id} }{name},
			meaning    => $$data{meanings}{$$entry{meaning_id} }{name},
			name       => $$entry{name},
			original   => $$data{originals}{$$entry{original_id} }{name},
			rating     => $$data{ratings}{$$entry{rating_id} }{name},
 			sex        => $$data{sexes}{$$entry{sex_id} }{name},
			source     => $$data{sources}{$$entry{source_id} }{name},
		};
	}

	return [sort{$$a{name} cmp $$b{name} } @name];

} # End of read_names_table.

# -----------------------------------------------

sub report_name
{
	my($self) = @_;
	my($name) = ucfirst lc $self -> name;

	die "No name specified\n" if (! $name);

	my($format) = '%-10s  %s';

	for my $item (@{$self -> read_names_table})
	{
		next if ($name ne $$item{name});

		for my $key (sort keys %$item)
		{
			say sprintf $format, $key, $$item{$key};
		}
	}

	# Return 0 for success and 1 for failure.

	return 0;

} # End of report_name.

# ----------------------------------------------

sub report_statistics
{
	my($self)   = @_;
	my($data)   = $self -> get_tables;
	my($format) = "%-15s  %7s";

	say sprintf $format, 'Table', 'Records';

	my($records);

	for my $table_name (sort keys %$data)
	{
		$records = $$data{$table_name};

		say sprintf $format, $table_name, scalar keys %$records;
	}

	# Return 0 for success and 1 for failure.

	return 0;

} # End of report_statistics.

# ----------------------------------------------

sub report_stop_words
{
	my($self)       = @_;
	my($data)       = $self -> get_tables;
	my($stop_words) = Lingua::EN::StopWordList -> new -> words;

	for my $table_name (grep{! /names/} values %{$self -> table_names})
	{
		my($result) = List::Compare -> new($stop_words, [map{$$data{$table_name}{$_}{name} } keys %{$$data{$table_name} }]);
		my(@match)  = $result -> get_intersection;

		if ($#match >= 0)
		{
			say "Table '$table_name' contains these stop words: ", join(', ', @match);
		}
	}

	# Return 0 for success and 1 for failure.

	return 0;

} # End of report_stop_words.

# ----------------------------------------------

sub table_names
{
	my($self) = @_;

	return
	{
		derivation => 'derivations',
		form       => 'forms',
		kind       => 'kinds',
		meaning    => 'meanings',
		name       => 'names',
		original   => 'originals',
		rating     => 'ratings',
		sex        => 'sexes',
		source     => 'sources',
	};

} # End of table_names.

# -----------------------------------------------

1;

=pod

=head1 NAME

Lingua::EN::GivenNames::Database - The interface to lingua.en.givennames.sqlite

=head1 Synopsis

See L<Lingua::EN::GivenNames/Synopsis> for a long synopsis.

=head1 Description

Documents the methods end-users need to access the SQLite database,
I<www.scraper.wikipedia.iso3166.sqlite>, which ships with this distro.

See L<Lingua::EN::GivenNames/Description> for a long description.

See scripts/export.as.csv.pl, scripts/export.as.html.pl and scripts/report.statistics.pl.

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing.

=head1 Constructor and initialization

new(...) returns an object of type C<Lingua::EN::GivenNames::Database>.

This is the class's contructor.

Usage: C<< Lingua::EN::GivenNames::Database -> new() >>.

This method takes a hash of options.

Call C<new()> as C<< new(option_1 => value_1, option_2 => value_2, ...) >>.

Available options:

=over 4

=item o attributes => $hash_ref

This is the hashref of attributes passed to L<DBI>'s I<connect()> method.

Default: {AutoCommit => 1, RaiseError => 1, sqlite_unicode => 1}

=back

=head1 Methods

This module is a sub-class of L<Lingua::EN::GivenNames> and consequently inherits its methods.

=head2 attributes($hashref)

Get or set the hashref of attributes passes to L<DBI>'s I<connect()> method.

Also, I<attributes> is an option to L</new()>.

=head2 get_name_count()

Returns the result of: 'select count(*) from names'.

=head2 new()

See L</Constructor and initialization>.

=head2 read_names_table()

Returns a hashref of hashrefs for this SQL: 'select * from names'.

The key of the hashref is the primary key (integer) of the I<names> table.

This is discussed further in L<Lingua::EN::GivenNames/Methods which return hashrefs>.

=head2 verbose($integer)

Get or set the verbosity level.

Also, I<verbose> is an option to L</new()>.

=head1 FAQ

For the database schema, etc, see L<Lingua::EN::GivenNames/FAQ>.

=head1 References

See L<Lingua::EN::GivenNames/References>.

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
