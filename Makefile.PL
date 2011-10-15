use inc::Module::Install;


# Define metadata
name            'Data-Random';
all_from        'lib/Data/Random.pm';


# Specific dependencies
requires        'Carp'              =>  0;

recommends      'Date::Calc'        =>  0;
recommends      'GD'                =>  0;

test_requires   'Test'              => 0;
test_requires   'Test::More'        => 0;
test_requires   'File::Spec'        => 0;


WriteAll;
