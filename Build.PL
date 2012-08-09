use Module::Build;

Module::Build -> new
(
	module_name    => 'Lingua::EN::GivenNames',
	license        => 'artistic',
	dist_abstract  => 'An SQLite database of derivations of English given names',
	dist_author    => 'Ron Savage <ron@savage.net.au>',
	build_requires =>
	{
		Test::More => 0.96,
		Test::Pod  => 1.44,
	},
	configure_requires =>
	{
		Module::Build => 0.3800,
	},
	requires =>
	{
		Config::Tiny             => 2.14,
		DBI                      => 1.622,
		DBIx::Admin::CreateTable => 2.07,
		DBIx::Table2Hash         => 1.17,
		Data::Dumper::Concise    => 2.020,
		ExtUtils::MakeMaker      => 6.62,
		feature                  => 1.20,
		File::ShareDir           => 1.03,
		File::Slurp              => 9999.19,
		File::Spec               => 3.33,
		Getopt::Long             => 2.38,
		HTML::HTML5::Entities    => 0.003,
		HTML::TreeBuilder        => 4.2,
		HTTP::Tiny               => 0.022,
		Hash::FieldHash          => 0.12,
		IO::File                 => 1.15,
		Lingua::EN::StopWordList => 1.00,
		List::Compare            => 0.37,
		open                     => 1.08,
		parent                   => 0.225,
		Pod::Usage               => 1.51,
		strict                   => 0.00,
		Text::CSV                => 1.21,
		Text::Xslate             => 1.5015,
		Unicode::CaseFold        => 0.02,
		warnings                 => 0.00,
	},
) -> create_build_script();
