use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		AUTHOR   => 'Ron Savage (ron@savage.net.au)',
		ABSTRACT => 'An SQLite database of derivations of English given names',
    ) : (),
	clean =>
	{
		FILES => 'blib/* Makefile MANIFEST Lingua-EN-GivenNames-*'
	},
	dist =>
	{
		COMPRESS => 'gzip',
		SUFFIX   => 'gz'
	},
	DISTNAME  => 'Lingua-EN-GivenNames',
	NAME      => 'Lingua::EN::GivenNames',
	PL_FILES  => {},
	PREREQ_PM =>
	{
		Test::More => 0.96,
		Test::Pod  => 1.44,
	},
	VERSION_FROM => 'lib/Lingua/EN/GivenNames.pm',
);
