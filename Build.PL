use 5.010;

use Module::Build;

my $class = Module::Build->subclass(
	class => 'My::Builder',
	code  => q{
		sub find_test_files {			
			if( eval "use Test::Manifest 1.21; 1" )
				{
				[ Test::Manifest::get_t_files( $ENV{TEST_lEVEL} // () ) ]
				}
			else
				{
				$_[0]->SUPER::find_test_files;
				}
			}
		},
	);

$class->new(
   module_name => 'PeGS::PDF',
   abstract    => 'Create PDF representations of Perl data structures',
   dist_author => 'brian d foy <bdfoy@cpan.org>',
   license     => 'perl',

   requires => {
		'perl'         => '5.8.8',
		'PDF::EasyPDF' => 0, 
		},

   build_requires => {
		'Test::More' => 0,
		},

   recommends => {
		'Test::Pod'           => '0',
		'Test::Pod::Coverage' => '0',
		'Test::Manifest'      => '1.21',
		},

   script_files => [],

   add_to_cleanup => [ 'PDF-*' ],

   create_makefile_pl => 'traditional',
)->create_build_script;
