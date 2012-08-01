package Lingua::EN::GivenNames::Database::Import;

use parent 'Lingua::EN::GivenNames::Database';
use feature qw/say unicode_strings/;
use open qw(:std :utf8);
use strict;
use warnings;
use warnings qw(FATAL utf8);

use Data::Dumper::Concise; # For Dumper().

use DBI;

use Encode; # For decode().

use File::Spec;

use Hash::FieldHash ':all';

use HTML::TreeBuilder;

use IO::File;

use Perl6::Slurp; # For slurp().

use Text::CSV;

use Unicode::CaseFold;  # For fc().
use Unicode::Normalize; # For NFD(), NFC().

fieldhash my %page_number => 'page_number';

our $VERSION = '1.00';

# ----------------------------------------------

sub _extract_derivation_set
{
	my($self, $sex, $file_name) = @_;
	my($root)   = HTML::TreeBuilder -> new;

	# This produces an erroneous result :-(.
	# my $content = slurp '< :raw', $file_name; # Scalar context!

	open(INX, '<', $file_name);
	binmode INX;
	my(@context) = <INX>;
	close INX;
	chomp @context;

	my($result) = $root -> parse_content(join('', @context) );

	my(@name);

	push @name, map
	{
		s/^\s+//;
		s/\s+$//;
		s/\s+/ /gs;
		s/\xc2//gs;          # Don't you just want to throttle some bastard.
		$_ =~ s/St\. /St /g; # Simplify by removing internal full-stops from saint names.
		$_;
	} $_ -> as_text for $root -> look_down(_tag => 'li');

	# Skip add-one lines where name is like ADEN, and the lines are
	# commentary in a stand-alone <ol> <li>1...</li> <li>2...</li> </ol> set.

	@name = map{"$sex. $_"} grep {/^[A-Z][A-Z]/} @name;

	$root -> delete();

	my($out_file_name) = File::Spec -> catfile($self -> data_dir, 'derivations.raw');

	# sub import_derivations() assumes the file is sorted.
	# This really means we parsed data/*.htm in order.

	open(OUT, '>>', $out_file_name) || die "Can't open(>> $out_file_name): $!\n";
	binmode OUT;
	print OUT map{"$_\n"} sort @name;
	close OUT;

	$self -> log(debug => "Updated $out_file_name");

} # End of _extract_derivation_set.

# ----------------------------------------------

sub extract_derivations
{
	my($self) = @_;
	my($page) = $self -> page_number;

	if ($page == 1)
	{
		$page = '';
	}
	else
	{
		$page = sprintf '_%02d', $page;
	}

	my($sex)          = $self -> sex;
	my($in_file_name) = File::Spec -> catfile($self -> data_dir, "${sex}_english_names$page.htm");

	$self -> log(debug => "Extracting derivations from $in_file_name");

	$self -> _extract_derivation_set($sex, $in_file_name);

	# Return 0 for success and 1 for failure.

	return 0;

} # End of extract_derivations.

# -----------------------------------------------

sub generate_derivation
{
	my($self, $item) = @_;

	return "$$item{kind} $$item{form} of $$item{source} $$item{original}, $$item{rating} '$$item{meaning}'";

} # End of generate_derivation.

# -----------------------------------------------

sub _init
{
	my($self, $arg)    = @_;
	$$arg{page_number} ||= 1; # Caller can set.

	return $self -> SUPER::_init($arg);

} # End of _init.

# ----------------------------------------------

sub import_derivations
{
	my($self)       = @_;
	my($derivation) = $self -> read_derivations;
	my($duplicate)  = 0;

	# Build lists to store all tables except 'names'.
	# Lastly, process the 'names' table.

	my(@derivation);
	my($s, %seen);

	for my $item (@$derivation)
	{
		$s = $self -> generate_derivation($item);

		if ($seen{$s})
		{
			$duplicate++;

			$self -> log(debug => "Skipping duplicate: $$item{name}: $s");

			next;
		}

		$seen{"$$item{name} $s"} = 1;
		$$item{derivation}       = $s;

		push @derivation, $item;
	}

	$self -> log(debug => "Skipping $duplicate duplicate derivations");

	my($table_name) = $self -> table_names;

	my(%foreign_key);

	# The sort here is just to help debugging.

	for my $table (sort grep{! /name/} keys %$table_name)
	{
		$foreign_key{$table} = $self -> write_table($$table_name{$table}, [map{$$_{$table} } @derivation]);
	}

	$self -> write_names($$table_name{name}, \@derivation, \%foreign_key);

} # End of import_derivations.

# ----------------------------------------------

sub _parse_definition
{
	my($self, $match_count, $matched, $key, $pattern, $unparsable, $candidate) = @_;
	my($match) = 0;

	my($derivation); # This is a temp var.
	my($form);
	my($kind);
	my($meaning);
	my($name);
	my($original);
	my($rating);
	my($sex, $source);

	if ($candidate =~ $pattern)
	{
		$form     = $4 || '';
		$kind     = $3;
		$meaning  = $8;
		$name     = $2;
		$original = $6;
		$rating   = $7;
		$sex      = $1;
		$source   = $5;

		# Warning: These must follow all the assignments above,
		# because they reset $1 .. $7.

		$form    =~ s/\s$//;
		$meaning =~ s/[,.]$//;
		$meaning =~ s/^\s//;
		$name    =~ s/\s+\(.+\)//;
		$rating  =~ s/\s$//;

		# Skip freaks which trick my 'parser'.

		if ($$unparsable{$name})
		{
			$self -> log(notice => "Ignoring candidate $candidate");
		}
		else
		{
			$match = 1;

			push @{$$matched{$key}{form} },       $form;
			push @{$$matched{$key}{kind} },       $kind;
			push @{$$matched{$key}{meaning} },    $meaning;
			push @{$$matched{$key}{name} },       $name;
			push @{$$matched{$key}{original} },   $original;
			push @{$$matched{$key}{rating} },     $rating;
			push @{$$matched{$key}{sex} },        $sex;
			push @{$$matched{$key}{source} },     $source;
		}
	}

	return $match;

} # End of _parse_definition.

# ----------------------------------------------

sub parse_derivations
{
	my($self)      = @_;
	my($file_name) = File::Spec -> catfile($self -> data_dir, 'derivations.raw');

	$self -> log(debug => "Processing $file_name");

	# This produces an erroneous result :-(.
	# my(@name) = slurp '< :raw', $file_name, {chomp => 1};

	open(INX, '<', $file_name) || die "Can't open($file_name): $!\n";
	binmode INX;
	my(@name) = <INX>;
	close INX;
	chomp @name;

	my(@unparsable) = map{tr/a-z/A-Z/; $_} slurp(File::Spec -> catfile($self -> data_dir, 'unparsable.txt'), {chomp => 1});

	$self -> log(debug => 'Names which are currently unparsable:');
	$self -> log(debug => $_) for sort @unparsable;

	my(%unparsable);

	@unparsable{@unparsable} = (1) x @unparsable;

	my($sub_pattern_1) = <<'EOS';
Anglicized|Breton|Contracted|Diminutive|Elaborated|
English\s+?and\s+?(?:French|German|Latin|Scottish)|
(?:(?:American|British)\s+?)?English|
Feminine|French|Irish\s+?Gaelic|
Latin|Latvian|Medieval\s+?English|Modern|
Old\s+?English|Pet|Polish|
Scottish(?:\s+Anglicized)?|Short|Slovak|Spanish|Unisex|
(?:V|v)ariant
EOS
	my($sub_pattern_2) = <<'EOS';
(?:(?:adopted|contracted|diminutive|elaborated|feminine|pet|short|unisex|variant)?\s*?
EOS
	# Note for 2 => Name: Beware 'NAME (Text):'. Also, text can contain ':'.

	my(%pattern) =
	(
		a => qr/
			(.+?)\.\s            # 1 => Sex.
			(.+?):\s*            # 2 => Name.
			($sub_pattern_1)\s+? # 3 => Kind.
			($sub_pattern_2)     # 4 => Form.
			(?:equivalent|form|spelling|use)\s+?)
			(?:of\s+?)?(.+?)\s+? # 5 => Source.
			(.+?)\s*?(?:,\s*?)?  # 6 => Original.
			((?:possibly\s+?)?meaning\s*?(?:simply\s*)?) # 7 => Rating.
			"(.+?)" # 8 => Meaning.
			/x,
		b => qr/
			(.+?)\.\s            # 1 => Sex.
			(.+?):\s*            # 2 => Name.
			($sub_pattern_1)\s+? # 3 => Kind.
			(form)\s+?                 # 4 => Form.
			(?:of\s+?)(.+?\s+?.+?)\s+? # 5 => Source.
			(.+?)(?:,\s*?)?            # 6 => Original.
			((?:possibly\s+?)?meaning\s*?(?:simply\s*)?) # 7 => Rating.
			"(.+?)" # 8 => Meaning.
			/x,
	);
	my($table_name) = $self -> table_names;

	# Values captured by the above regexp are stored in a set of arrayrefs.
	# The arrayref $matched{$key}{derivation} is not used.

	my(%matched);

	for my $key (keys %pattern)
	{
		$matched{$key}{$_} = [] for (keys %$table_name);
	}

	my($match_count) = 0;

	my($found);
	my(@mis_match);

	for my $name (@name)
	{
		$found = 0;

		for my $key (sort keys %pattern)
		{
			if ($self -> _parse_definition(\$match_count, \%matched, $key, $pattern{$key}, \%unparsable, $name) )
			{
				$found = $key;

				last;
			}
		}

		if ($found)
		{
			$match_count++;
		}
		else
		{
			# Rearrange $name so the actual name is at the end,
			# and the prefix is 'notice: ...'.
			# This means we can sort the output looking for patterns to match.

			if ($name =~ /(.+?):\s*(.+)/s)
			{
				$name = "1: $2 | $1";
			}
			elsif ($name !~ /^[A-Z]{2,}/)
			{
				$name = "2: $name";
			}
			else
			{
				$name = "3: $name";
			}

			push @mis_match, $name;
		}
	}

	my($mismatch_count) = scalar @name - $match_count;

	$self -> log(debug => "Target count: " . scalar @name . ". Match count: $match_count. Mis-match count: $mismatch_count");

	my($csv) = Text::CSV -> new({binary => 1});

	my(@column);
	my(@row);

	for my $key (keys %pattern)
	{
		# Loop over all stacks. Any field besides kind could be used.

		for my $index (0 .. $#{$matched{$key}{kind} })
		{
			@column = ();

			for my $set (sort grep{! /derivation/} keys %$table_name)
			{
				push @column, $matched{$key}{$set}[$index];
			}

			die "Can't combine fields into a CSV string\n" if (! $csv -> combine(@column) );

			push @row, $csv -> string;
		}
	}

	my($derived_file_name) = File::Spec -> catfile($self -> data_dir, 'derivations.csv');

	open(OUT, '>>', $derived_file_name) || die "Can't open($derived_file_name): $!\n";
	binmode OUT;
	print OUT join(',', sort grep{! /derivation/} keys %$table_name), "\n";
	print OUT map{"$_\n"} @row;
	close OUT;

	$self -> log(debug => "Updated $derived_file_name");

	my($mismatch_file_name) = File::Spec -> catfile($self -> data_dir, 'mismatches.log');

	open(OUT, '>>', $mismatch_file_name) || die "Can't open($mismatch_file_name): $!\n";
	binmode OUT;
	print OUT map{"$_\n"} @mis_match;
	close OUT;

	$self -> log(debug => "Updated $mismatch_file_name");

	my($parse_file_name) = File::Spec -> catfile($self -> data_dir, 'parse.log');

	open(OUT, '>>', $parse_file_name) || die "Can't open($parse_file_name): $!\n";
	print OUT "Updated $file_name. Target count: ", scalar @name, ". Match count: $match_count. Mis-match count: $mismatch_count. \n";
	close OUT;

	$self -> log(debug => "Updated $parse_file_name");

} # End of parse_derivations.

# -----------------------------------------------

sub read_csv_file
{
	my($self, $file_name) = @_;
	my($csv) = Text::CSV -> new({allow_whitespace => 1, binary => 1});
	my($io)  = IO::File -> new($file_name, 'r');

	$csv -> column_names($csv -> getline($io) );

	return $csv -> getline_hr_all($io);

} # End of read_csv_file.

# ----------------------------------------------

sub read_derivations
{
	my($self)      = @_;
	my($file_name) = File::Spec -> catfile($self -> data_dir, 'derivations.csv');
	my($line)      = $self -> read_csv_file($file_name);
	my($count)     = 0;

	$self -> log(debug => "File: $file_name. Derivation count: " . scalar @$line);

	my(%derivation);

	for my $field (@$line)
	{
		$count++;

		for my $key (keys %$field)
		{
			if (! $$field{$key})
			{
				$self -> log(debug => join(', ', map{"$_ => $$field{$_}"} sort keys %$field) );

				die "$count: Missing value for key $key";
			}

			$derivation{$key}                 = {} if (! $derivation{$key});
			$derivation{$key}{$$field{$key} } = 1;
		}
	}

	$self -> validate_derivations($file_name, \%derivation);

	return \@$line;

} # End of read_derivations.

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

sub validate_derivations
{
	my($self, $file_name, $derivation) = @_;
	my($expected_key) = $self -> table_names;

	for my $key (sort keys %$derivation)
	{
		die "Input file: $file_name. Unexpected key: $key. \n" if (! $$expected_key{$key});
	}

	for my $name (sort keys %{$$derivation{name} })
	{
		$self -> log(notice => "Non-ASCII name: $name") if ($name !~ /^[-A-Za-z]+$/);
	}

} # End of validate_derivations.

# -----------------------------------------------

sub write_names
{
	my($self, $table, $derivation, $foreign_key) = @_;
	my($table_name) = $self -> table_names;

	# Convert strings to foreign keys.

	my(@data);

	for my $item (@$derivation)
	{
		for my $table (grep{! /name/} keys %$table_name)
		{
			$$item{$table} = $$foreign_key{$table}{$$item{$table} };
		}

		push @data, $item;
	}

	$self -> dbh -> do("delete from $$table_name{name}");

	my($i)   = 0;
	my($sql) = "insert into $$table_name{name} (derivation_id, form_id, kind_id, meaning_id, original_id, rating_id, sex_id, source_id, fc_name, name) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
	my($sth) = $self -> dbh -> prepare($sql) || die "Unable to prepare SQL: $sql\n";

	my($name);
	my(@record);

	for my $item (sort{$$a{name} cmp $$b{name} } @data)
	{
		$i++;

		$name = decode('utf8', ucfirst lc $$item{name});

		@record = ($$item{derivation}, $$item{form}, $$item{kind}, $$item{meaning}, $$item{original}, $$item{rating}, $$item{sex}, $$item{source}, fc $name, $name);

		$self -> log(debug => join(', ', @record) ) if ($self -> verbose > 1);

		$sth -> execute(@record);
	}

	$sth -> finish;

	$self -> log(debug => "Saved $i entries in the $$table_name{name} table");

} # End of write_names.

# -----------------------------------------------

sub write_table
{
	my($self, $table, $item) = @_;

	my(%seen);

	$seen{$_} = 1 for @$item;

	$self -> dbh -> do("delete from $table");

	my($i)   = 0;
	my($sql) = "insert into $table (fc_name, name) values (?, ?)";
	my($sth) = $self -> dbh -> prepare($sql) || die "Unable to prepare SQL: $sql\n";

	for my $key (sort keys %seen)
	{
		$i++;

		$seen{$key} = $i;

		$sth -> execute(fc decode('utf8', $key), decode('utf8', $key));
	}

	$sth -> finish;

	$self -> log(debug => "Saved $i entries in the $table table");

	return {%seen};

} # End of write_table.

# -----------------------------------------------

1;

=pod

=head1 NAME

Lingua::EN::GivenNames::Database::Import - Part of the interface to locale.givennames.en.sqlite

=head1 Synopsis

See L<Lingua::EN::GivenNames/Synopsis>.

=head1 Description

Documents the methods used to populate the SQLite database,
I<locale.givennames.en.sqlite>, which ships with this distro.

See L<Lingua::EN::GivenNames/Description> for a long description.

=head1 Distributions

This module is available as a Unix-style distro (*.tgz).

See http://savage.net.au/Perl-modules.html for details.

See http://savage.net.au/Perl-modules/html/installing-a-module.html for
help on unpacking and installing.

=head1 Constructor and initialization

new(...) returns an object of type C<Lingua::EN::GivenNames::Database::Import>.

This is the class's contructor.

Usage: C<< Lingua::EN::GivenNames::Database::Import -> new() >>.

This method takes a hash of options.

Call C<new()> as C<< new(option_1 => value_1, option_2 => value_2, ...) >>.

Available options (these are also methods):

=over 4

=back

=head1 Methods

This module is a sub-class of L<Lingua::EN::GivenNames::Database> and consequently inherits its methods.

=head2 extract_derivations()

=head2 import_derivations()

=head2 new()

See L</Constructor and initialization>.

=head2 parse_derivations()

=head2 read_derivations()

=head2 table_names()

=head2 validate_derivations()

=head2 write_names()

=head2 write_table()

=head1 FAQ

For the database schema, etc, see L<Lingua::EN::GivenNames/FAQ>.

=head2 How is the input scanned?

The regexps in sub parse_derivations() split each line of data/derivations.raw into these fields:

=over 4

=item o $1 => Sex

=item o $2 => Name

=item o $3 => Kind

=item o $4 => Form

=item o $5 => Source

=item o $6 => Original

=item o $7 => Meaning

=back

=head3 Matches using pattern 'a'

'male. ALLISTAIR: Anglicized form of Scottish Gaelic Alastair, meaning "defender of mankind."' becomes the
hashref (with keys in alphabetical order):

	{
		form     => 'form',
		kind     => 'Anglicized',
		meaning  => 'defender of mankind',
		name     => 'ALLISTAIR',
		original => 'Alastair',
		sex      => 'male',
		source   => 'Scottish Gaelic',
	}

The derivation is:

'male. ANTONY: Variant spelling of English Anthony, possibly meaning "invaluable."' becomes:

	{
		form     => 'spelling',
		kind     => 'Variant',
		meaning  => 'invaluable',
		name     => 'ANTONY',
		original => 'Anthony',
		sex      => 'male',
		source   => 'English',
	}

The derivation is:

In each case the derivation is built by sub generate_derivation($item) as:

	"$$item{kind} $$item{form} of $$item{source} $$item{original}: $$item{meaning}"

=head3 Matches using pattern 'b'

'female. ANTONIA: Feminine form of Roman Latin Antonius, possibly meaning "invaluable." In use by the English, Italians and Spanish. Compare with another form of Antonia.'
becomes:

	{
		form     => 'form',
		kind     => 'Feminine',
		meaning  => 'invaluable',
		name     => 'ANTONIA',
		original => 'Anthony',
		sex      => 'female',
		source   => 'Roman Latin',
	}

The derivation is: Feminine form of Roman Latin Antonius: invaluable

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
