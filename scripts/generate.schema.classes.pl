#!/usr/bin/env perl

use strict;
use warnings;

use DBIx::Class::Schema::Loader 'make_schema_at';

use File::ShareDir;

# -----------------------------------------------

my($module)      = 'Lingua::EN::GivenNames';
(my $package     = $module) =~ s/::/-/g;
my($dir_name)    = $ENV{AUTHOR_TESTING} ? 'share' : File::ShareDir::dist_dir($package);
my($sqlite_file) = File::Spec -> catfile($dir_name, 'lingua.en.givennames.sqlite');

make_schema_at
(
	"$module\::Schema",
	{
		dump_directory     => './lib',
		skip_load_external => 1,
	},
	[
		'dbi:SQLite:dbname=' . $sqlite_file, '', '',
	],
);
