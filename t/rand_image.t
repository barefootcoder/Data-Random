use strict;
use Test;

BEGIN { plan tests => 1 }

use lib qw(..);
use Data::Random qw( rand_image );
use File::Spec;

print $Data::Random::VERSION,"\n";

use vars qw( $imagefile );

$imagefile = File::Spec->tmpdir().'/Data_Random_'.time().'.tmp';


# Test writing an image to a file
{
    open(FILE, ">$imagefile");
    binmode(FILE);
    print FILE rand_image( bgcolor => [0, 0, 0] );
    close(FILE);
    
    ok(!(-z $imagefile));
}


END {
    unlink($imagefile);
}
