package Lingua::EN::GivenNames::Database::Export;

use open qw/:std :utf8/;
use parent 'Lingua::EN::GivenNames::Database';
use strict;
use warnings;

use Encode; # For encode().

use Hash::FieldHash ':all';

use Text::Xslate 'mark_raw';

use Unicode::Normalize; # For NFC().

fieldhash my %csv_file      => 'csv_file';
fieldhash my %templater     => 'templater';
fieldhash my %web_page_file => 'web_page_file';

our $VERSION = '1.00';

# -----------------------------------------------

sub as_csv
{
	my($self) = @_;

	my(@row);

	push @row,
	[
		qw/id name derivation form kind meaning rating original sex source/
	];

	for my $name (@{$self -> read_names_table})
	{
		push @row,
		[
			$$name{id},
			$$name{name},
			$$name{derivation},
			$$name{form},
			$$name{kind},
			$$name{meaning},
			$$name{original},
			$$name{rating},
			$$name{sex},
			$$name{source},
		];
	}

	open(OUT, '>', $self -> csv_file) || die "Can't open file: " . $self -> csv_file . "\n";

	for (@row)
	{
		print OUT '"', join('","', @$_), '"', "\n";
	}

	close OUT;

	$self -> log(debug => 'Wrote ' . $self -> csv_file);

}	# End of as_csv.

# ------------------------------------------------

sub as_html
{
	my($self)      = @_;
	my($config)    = $self -> config;
	my($name_data) = $self -> build_names_data;

	open(OUT, '>', $self -> web_page_file) || die "Can't open file: " . $self -> web_page_file . "\n";
	binmode(OUT);

	print OUT $self -> templater -> render
		(
			'given.names.tx',
			{
				default_css => "$$config{_}{css_url}/default.css",
				name_count  => $#$name_data - 1,
				name_data   => $name_data,
				version     => $VERSION,
			}
		);

	close OUT;

	$self -> log(debug => 'Wrote ' . $self -> web_page_file);

} # End of as_html.

# -----------------------------------------------

sub build_names_data
{
	my($self) = @_;

	my(@tr);

	push @tr, [{td => 'Id'}, {td => 'Name'}, {td => 'Sex'}, {td => 'Derivation'}];

	for my $name (@{$self -> read_names_table})
	{
		push @tr,
		[
			{td => $$name{id} },
			{td => $$name{name} },
			{td => $$name{sex} },
			{td => $$name{derivation} },
		];
	}

	push @tr, [{td => 'Id'}, {td => 'Name'}, {td => 'Sex'}, {td => 'Derivation'}];

	return [@tr];

} # End of build_names_data.

# -----------------------------------------------

sub _init
{
	my($self, $arg)      = @_;
	$$arg{csv_file}      ||= 'given.names.csv'; # Caller can set.
	$$arg{templater}     = '';
	$$arg{web_page_file} ||= 'given.names.html'; # Caller can set.
	$self                = $self -> SUPER::_init($arg);

	$self -> templater
	(
		Text::Xslate -> new
		(
		 input_layer => '',
		 path        => ${$self -> config}{_}{template_path},
		)
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

# ------------------------------------------------

1;

=pod

=head1 NAME

Lingua::EN::GivenNames::Database::Export - Export lingua.en.givennames.sqlite as CSV and HTML

=head1 Synopsis

See L<Lingua::EN::GivenNames/Synopsis>.

=head1 Description

Documents the methods end-users need to export the SQLite database,
I<lingua.en.givennames.sqlite>, which ships with this distro, as either CSV or HTML.

See scripts/export.as.csv.pl and scripts/export.as.html.pl.

The input to these scripts is shipped as share/lingua.en.givennames.sqlite.

The output of these scripts is shipped as:

=over 4

=item o data/given.names.csv

=item o data/given.names.html

This file is on-line at: L<http://savage.net.au/Perl-modules/html/Locale/GivenNames/en/given.names.html>.

=back

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing.

=head1 Constructor and initialization

new(...) returns an object of type C<Lingua::EN::GivenNames::Database::Export>.

This is the class's contructor.

Usage: C<< Lingua::EN::GivenNames::Database::Export -> new() >>.

This method takes a hash of options.

Call C<new()> as C<< new(option_1 => value_1, option_2 => value_2, ...) >>.

Available options (these are also methods):

=over 4

=item o names_file => $a_csv_file_name

Specify the name of the CSV file to which given name data is exported.

Default: 'names.csv'.

=item o web_page_file => $a_html_file_name

Specify the name of the HTML file to which country and subcountry data is exported.

See htdocs/assets/templates/locale/givennames/en/given.names.tx for the web page template used.

*.tx files are processed with L<Text::Xslate>.

Default: 'given.names.html'.

=back

=head1 Methods

This module is a sub-class of L<Lingua::EN::GivenNames::Database> and consequently inherits its methods.

=head2 as_csv()

Export the SQLite database to a CSV file.

=head2 as_html()

Export the SQLite database to a HTML file.

=head2 build_name_data()

Builds part of a HTML table, and returns an arrayref of arrayrefs of hashrefs suitable for L<Text::Xslate>.

=head2 names_file($file_name)

Get or set the name of the CSV file to which given name data is exported.

Also, I<names_file> is an option to L</new()>.

=head2 new()

See L</Constructor and initialization>.

=head2 web_page_file($file_name)

Get or set the name of the HTML file to which given name data is exported.

Also, I<web_page_file> is an option to L</new()>.

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
