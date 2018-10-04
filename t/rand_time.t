use Test2::V0;
use Test2::Tools::Spec;

BEGIN { use Test::MockTime qw( set_fixed_time ); }

use Data::Random qw( rand_time );
use Time::Piece;

describe 'Bad input' => sub {
    my $time;

    it 'Warns if min time is later than max time' => sub {
        like warning
            { $time = rand_time( max => '10:00:00', min => '11:00:00' ) },
            qr/later than/;

        is $time, U(), 'Returns undefined';
    };

    it 'Warns if min time is not a time' => sub {
        like warning
            { $time = rand_time( min => 'not a time' ) },
            qr/not in valid time format/;

        is $time, U(), 'Returns undefined';
    };

    it 'Warns if max time is not a time' => sub {
        like warning
            { $time = rand_time( max => 'not a time' ) },
            qr/not in valid time format/;

        is $time, U(), 'Returns undefined';
    };
};

describe 'Time boundaries' => sub {
    my ($min, $max, %args, %check);

    before_all 'Fix time' => sub {
        set_fixed_time('1987-12-18T04:05:06Z');
    };

    before_each 'Create Time::Piece objects' => sub {
        $min = Time::Piece->strptime( $check{min} // '00:00:00', '%T' )->epoch;
        $max = Time::Piece->strptime( $check{max} // '23:59:59', '%T' )->epoch;

        srand(12345); # Generates 05:24:28
    };

    case 'No params' => sub {
        %check = %args = ();
    };

    case 'With min' => sub {
        %check = %args = ( min => '6:0:0' );
    };

    case 'With max' => sub {
        %check = %args = ( max => '4:0:0' );
    };

    case 'With min and max' => sub {
        %check = %args = ( min => '9:0:0', max => '10:0:0' );
    };

    case 'With min and max as now' => sub {
        %args  = ( min => 'now',      max => 'now' );
        %check = ( min => '04:05:06', max => '04:05:06' );
    };

    tests 'Random time is between boundaries' => sub {
        my $rand_time = rand_time( %args );

        like $rand_time, qr/^\d{1,2}:\d{1,2}:\d{1,2}$/, 'rand_time format';

        my $result = Time::Piece->strptime( $rand_time, '%T' )->epoch;

        note $rand_time;
        cmp_ok $result, '>=', $min, 'rand_date >= minimum';
        cmp_ok $result, '<=', $max, 'rand_date <= maximum';
    };
};

done_testing;
