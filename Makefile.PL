use ExtUtils::MakeMaker 6.48;

require 5.008;

eval "use Test::Manifest 1.21";

WriteMakefile(
	'NAME'	        => 'PeGS::PDF',
	'ABSTRACT_FROM' => 'lib/PeGS/PDF.pm',

	'VERSION_FROM'  => 'lib/PeGS/PDF.pm',
	'LICENSE'       => 'perl',
	'AUTHOR'        => 'brian d foy <bdfoy@cpan.org>',

	'PREREQ_PM'     => {
		'PDF::EasyPDF' => '0',
		'List::Util'   => '0', 
		},

	'META_MERGE' => {
        'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url  => 'git@github.com:briandfoy/pegs-pdf.git',
				web  => 'https://github.com/briandfoy/pegs-pdf',
				},
			},
		},

	clean  => { FILES    => q|File-Find-Closures-*| },
	);
