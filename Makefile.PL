use ExtUtils::MakeMaker;

require 5.008;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'PeGS::PDF',
	'ABSTRACT'     => 'This is what the module does',
	'VERSION_FROM' => 'lib/PeGS/PDF.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	clean  => { FILES    => q|PeGS-PDF-*| },

	);
