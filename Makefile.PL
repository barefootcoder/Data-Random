use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Data::Random',
    'VERSION_FROM' => 'Random.pm',      # finds $VERSION
    'PMLIBDIRS'    => ['Random'],
    'PREREQ_PM'    => {},
);
