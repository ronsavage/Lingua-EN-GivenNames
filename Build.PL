use Module::Build;

Module::Build -> new
(
 module_name    => 'Lingua::EN::GivenNames',
 license        => 'artistic',
 dist_abstract  => 'SQLite database of derivations of given names',
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
) -> create_build_script();
