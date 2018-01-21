use Test2::V0 -srand => 123456;
use Test2::Tools::Spec;

eval q{ use GD };
skip_all 'GD not installed' if $@;

use Data::Random qw( rand_image );
use File::Temp;

describe 'Random image tests' => sub {
    tests 'Create a random image' => sub {
        my ($fh, $imagefile) = File::Temp::tempfile();
        binmode($fh);
        print $fh rand_image( bgcolor => [ 0, 0, 0 ] );
        close($fh);

        ok !( -z $imagefile );
    };
};

done_testing;
