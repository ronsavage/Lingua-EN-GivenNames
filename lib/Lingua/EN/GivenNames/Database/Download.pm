package Lingua::EN::GivenNames::Database::Download;

use parent 'Lingua::EN::GivenNames::Database';
use feature qw/say unicode_strings/;
use open qw(:std :utf8);
use strict;
use warnings;
use warnings qw(FATAL utf8);

use File::Spec;

use Hash::FieldHash ':all';
use HTML::HTML5::Entities; # For decode_entities().

use HTTP::Tiny;

fieldhash my %url => 'url';

our $VERSION = '1.00';

# -----------------------------------------------

sub get_1_page
{
	my($self, $url, $data_file) = @_;

	my($response) = HTTP::Tiny -> new -> get($url);

	if (! $$response{success})
	{
		$self -> log(error => "Failed to get $url");
		$self -> log(error => "HTTP status: $$response{status} => $$response{reason}");

		if ($$response{status} == 599)
		{
			$self -> log(error => "Exception message: $$response{content}");
		}

		# Return 0 for success and 1 for failure.

		return 1;
	}

	decode_entities $$response{content};

	open(OUT, '>', $data_file) || die "Can't open file: $data_file: $!\n";
	print OUT $$response{content};
	close OUT;

	$self -> log(info => "Downloaded '$url' to '$data_file'");

	# Return 0 for success and 1 for failure.

	return 0;

} # End of get_1_page.

# -----------------------------------------------

sub get_name_pages
{
	my($self)  = @_;
	my(%limit) = %{$self -> page_counts};

	my($delay, $data_file);
	my($file_name);
	my($page);
	my($result);
	my($url);

	for my $sex (qw/male/)
	{
		$file_name = "${sex}_english_names";

		for my $page_number (16 .. $limit{$sex})
		{
			# Generate input and output url/file names.

			$data_file = File::Spec -> catfile($self -> data_dir, $file_name);
			$url       = $self -> url . $file_name;

			if ($page_number > 1)
			{
				$page      = sprintf '_%02d', $page_number;
				$data_file .= $page;
				$url       .= $page;
			}

			$data_file .= '.htm';
			$url       .= '.htm';

			# Sleep randomly to avoid causing displeasure.

			$delay = 30 + int rand 1000;

			$self -> log(info => "Sleeping for $delay seconds before processing '$url' => '$data_file'");

			sleep $delay;

			$result = $self -> get_1_page($url, $data_file);
		}
	}

	return $result;

} # End of get_name_pages.

# -----------------------------------------------

sub _init
{
	my($self, $arg) = @_;
	$$arg{url}      = 'http://www.20000-names.com/';
	$self           = $self -> SUPER::_init($arg);

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

# -----------------------------------------------

1;

=pod

=head1 NAME

Lingua::EN::GivenNames::Database::Download - Download various pages http://www.20000-names.com/

=head1 Synopsis

See L<Lingua::EN::GivenNames/Synopsis>.

=head1 Description

Downloads these pages:

Input: L<http://www.20000-names.com/female_english_names.htm>.

Output: data/female_english_names.htm.

See scripts/get.name.pages.pl .

Note: These pages have been downloaded, and are shipped with the distro.

=head1 Constructor and initialization

new(...) returns an object of type C<Lingua::EN::GivenNames::Database::Download>.

This is the class's contructor.

Usage: C<< Lingua::EN::GivenNames::Database::Download -> new() >>.

This method takes a hash of options.

Call C<new()> as C<< new(option_1 => value_1, option_2 => value_2, ...) >>.

Available options (these are also methods):

=over 4

=item o code2 => $2_letter_code

Specifies the code2 of the country whose subcountry page is to be downloaded.

=back

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing.

=head1 Methods

This module is a sub-class of L<Lingua::EN::GivenNames::Database> and consequently inherits its methods.

=head2 code2($code)

Get or set the 2-letter country code of the country or subcountry being processed.

See L</get_subcountry_page()>.

Also, I<code2> is an option to L</new()>.

=head2 get_1_page($url, $data_file)

Download $url and save it in $data_file. $data_file normally takes the form 'data/*.html'.

=head2 get_country_pages()

Download the 2 country pages:

L<http://en.wikipedia.org/wiki/ISO_3166-1_alpha-3>.

L<http://en.wikipedia.org/wiki/ISO_3166-2>.

See L<Lingua::EN::GivenNames/Description>.

=head2 get_subcountry_page()

Download 1 subcountry page, e.g. http://en.wikipedia.org/wiki/ISO_3166:$code2.html.

Warning. The 2-letter code of the subcountry must be set with $self -> code2('XX') before calling this
method.

See L<Lingua::EN::GivenNames/Description>.

=head2 get_subcountry_pages()

Download all subcountry pages which have not been downloaded.

See L<Lingua::EN::GivenNames/Description>.

=head2 new()

See L</Constructor and initialization>.

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
