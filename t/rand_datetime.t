use Test2::V0 -srand => 123456;
use Test2::Tools::Spec;

use Data::Random qw( rand_datetime );
use Time::Piece;

describe 'Time tests' => sub {
    my ($min_date, $max_date, $case, $today);

    before_all 'Get today' => sub { $today = localtime };

    before_each 'Create Time::Piece objects' => sub {
        $min_date = Time::Piece->strptime( $case->{min}, '%Y-%m-%d %H:%M:%S' );
        $max_date = Time::Piece->strptime( $case->{max}, '%Y-%m-%d %H:%M:%S' );
    };

    case 'max now' => sub {
        $case = {
            args => { min => '2014-07-11 4:00:00', max => 'now' },
            min => '2014-07-11 4:00:00',
            max => $today->ymd . ' ' . $today->hms,
        };
    };

    case 'min now' => sub {
        $case = {
            args => { min => 'now' },
            min => $today->ymd . ' ' . $today->hms,
            max => $today->add_years(1)->ymd . ' ' . $today->hms,
        };
    };

    case 'min && max' => sub {
        $case = {
            args => { min => '2015-3-1 19:0:0', max => '2015-5-10 8:00:00' },
            min => '2015-03-01 19:00:00',
            max => '2015-05-10 08:00:00',
        };
    };

    case 'min' => sub {
        $case = {
            args => { min => '1979-08-02 00:00:00' },
            min => '1979-08-02 00:00:00',
            max => '1980-08-02 23:59:59',
        };
    };

    case 'no args' => sub {
        $case = {
            args => {},
            min  => $today->ymd . ' ' . $today->hms,
            max  => $today->add_years(1)->ymd .' ' . $today->hms,
        };
    };

    tests 'Random date is between boundaries' => sub {
        for (0 .. 999) {
            my $rand_datetime = rand_datetime( %{$case->{args}} );

            like $rand_datetime,
                qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/,
                'rand_datetime format';

            my $result = Time::Piece
                ->strptime( $rand_datetime, '%Y-%m-%d %H:%M:%S' );

            cmp_ok $result, '>=', $min_date, 'rand_date >= minimum';
            cmp_ok $result, '<=', $max_date, 'rand_date <= maximum';
        }
    };
};

done_testing;

