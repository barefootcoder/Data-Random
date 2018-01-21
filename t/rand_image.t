use Test2::V0;
use Test2::Require::Module 'GD';
use Test2::Tools::Spec;

use Data::Random qw( rand_image );
use File::Temp qw( tempfile );

describe 'Random image tests' => sub {
    my ($fh, $filename, %args, %check, $image);

    before_each 'Create file'    => sub {
        ($fh, $filename) = tempfile( UNLINK => 0 );
         srand( 123456 ); # Produces a 95 x 68 pixel image
    };

    around_each 'Open and close' => sub {
        binmode $fh;
        print $fh rand_image( %args ) and close $fh;
        ok $image = GD::Image->new( $filename ), 'Can read image file';
        shift->();
    };

    after_each  'Remove file' => sub {
        unlink $filename;
    };

    describe 'Dimension controls' => sub {
        case 'No arguments' => sub {
            %check = %args = ();
        };

        case 'Specific width' => sub {
            %check = %args = ( width => 33 );
            $check{height} = 95;
        };

        case 'Specific height' => sub {
            %check = %args = ( height => 33 );
        };

        case 'Minimum width' => sub {
            %args = ( minwidth => 80 );
            %check = ( width => 99 );
        };

        case 'Maximum width' => sub {
            %args = ( maxwidth => 60 );
            %check = ( width => 57 );
        };

        case 'Maximum height' => sub {
            %args = ( maxheight => 50 );
            %check = ( height => 34 );
        };

        case 'Minimum height' => sub {
            %args = ( minheight => 80 );
            %check = ( height => 94 );
        };

        it 'Controls the size of the image' => sub {
            note 'H' . $image->height . ' x W' . $image->width;

            is $image->height, $check{height} // 68, 'Correct height';
            is $image->width,  $check{width}  // 95, 'Correct width';
        };
    };

    describe 'Color options' => sub {
        case 'No arguments' => sub {
            %check = %args = ();
        };

        case 'Background' => sub {
            %check = %args = ( bgcolor => [ 1, 2, 3 ] );
        };

        case 'Foreground' => sub {
            %check = %args = ( fgcolor => [ 3, 2, 1 ] );
        };

        case 'Both' => sub {
            %check = %args = ( bgcolor => [ 3, 2, 1], fgcolor => [ 1, 2, 3 ] );
        };

        it 'Sets the colors in the image' => sub {
            is [ $image->rgb(0) ], $check{bgcolor},
                'Correct background color' if $args{bgcolor};

            is [ $image->rgb(1) ], $check{fgcolor},
                'Correct foreground color' if $args{fgcolor};

            is $image->trueColor, F(), 'Image is palette based';
            is $image->colorsTotal, 2, 'Has foreground and background colors';
        };
    };

};

describe 'Pixel options' => sub {
    my (%args, %check, $img, $pixels, $override);

    before_all 'Mock' => sub {
        $override = mock 'GD::Image', override => [
            png => sub ($;$) { $img = shift },
            setPixel => sub ($$$$) { $pixels++ },
        ];
    };

    before_each 'Reset' => sub {
        $pixels = 0;
        srand(9); # Produces a 1 x 10 image with 8 coloured pixels
    };

    case 'No arguments' => sub {
        %args = ();
    };

    case 'Sets specific pixel count' => sub {
        %check = %args = ( pixels => 10 );
    };

    case 'Minimum pixel count' => sub {
        %args = ( width => 10, height => 10, minpixels => 99 );
        $check{pixels} = 99;
    };

    case 'Maximum pixel count' => sub {
        %args = ( width => 10, height => 10, maxpixels => 0 );
        $check{pixels} = 0;
    };

    case 'Conflicting values' => sub {
        # minpixels wins
        %args = ( width => 10, height => 10, maxpixels => 10, minpixels => 90 );
        $check{pixels} = 90;
    };

    it 'Sets the colors in the image' => sub {
        rand_image( %args );
        is $pixels, $check{pixels} // 8;
    };
};

describe 'Edge cases' => sub {
    it 'Warns if it cannot load GD' => sub {
        no strict 'refs';
        local *{'Data::Random::require'} = sub { die 'Died' };
        like warning { rand_image() }, qr/Died/;
    };
};

done_testing;
