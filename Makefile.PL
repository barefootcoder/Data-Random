use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Data::Random',
    'VERSION_FROM'	=> 'Random.pm', # finds $VERSION
    'PMLIBDIRS' => [ 'Random' ],
);
