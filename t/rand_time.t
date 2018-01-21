use Test2::V0 -srand => 123456;
use Test2::Tools::Spec;

use Data::Random qw( rand_time );
use Test::MockTime qw( set_fixed_time );
use Time::Piece;

set_fixed_time('2018-01-21T18:54:00Z');

describe 'Test time parameters' => sub {
    my ($case);

    case 'No params' => sub {
        $case = {};
    };

    case 'With min' => sub {
        $case = { min => '4:0:0' };
    };

    case 'With max' => sub {
        $case ={ max => '4:0:0' };
    };

    case 'With min and max' => sub {
        $case = { min => '9:0:0', max => '10:0:0' };
    };

    describe 'For each case' => { flat => 1}, sub {
        my ($min_secs, $max_secs, $iterations);

        before_all 'Determine test granularity' => sub {
            $min_secs = defined $case->{min}
                ? _to_secs($case->{min}) : 0;

            $max_secs = defined $case->{max}
                ? _to_secs($case->{max}) : _to_secs('23:59:59');

            # Running once for every possible value doesn't actually
            # guarantee that we will _get_ every possible value, of course,
            # since it's a randomly generated time.  Running 10 times for
            # every possible value pretty much guarantees that, but it also
            # takes forever.  So let's run 10x in the case of automated
            # testers (like CPAN Testers), and just half that many otherwise
            # (to keep installs speedy).

            $iterations = $max_secs - $min_secs + 1;
            $iterations *= $ENV{AUTOMATED_TESTING} ? 10 : .5;
        };

        tests 'Random time is between boundaries' => sub {
            my $errors = 0;

            for ( 1 .. $iterations ) {
                my $time = rand_time( %{$case} );
                my $secs = _to_secs($time);

                my $error = 0;
                $error = 1 unless defined($secs)
                    and ($secs >= $min_secs)
                    and ($secs <= $max_secs);

                if ($error) {
                    $errors += 1;
                    note 'Failed with ' . $time;
                }
            }
            ok $errors == 0, 'foo';
        };
    };
};

describe 'Test special parameters' => sub {
    my ($case);

    case 'With min and max set to now' => sub {
        $case = { min => 'now', max => 'now' };
    };

    tests 'Random time is now' => sub {
        my $time = rand_time( %{$case} );
        is  [ map { s/^0//; $_ } split /:/, $time ],
            [ ( localtime() )[ 2, 1, 0 ] ],
            'Random time constrained to a second works';
    };
};

done_testing;

sub _to_secs {
    my $time = shift;

    my ( $hour, $min, $sec ) = split ( /\:/, $time );

    return undef if ( $hour > 23 ) || ( $hour < 0 );
    return undef if ( $min > 59 )  || ( $min < 0 );
    return undef if ( $sec > 59 )  || ( $sec < 0 );

    return $hour * 3600 + $min * 60 + $sec;
}
