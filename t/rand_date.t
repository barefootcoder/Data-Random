use Test2::V0 -srand => 123456;
use Test2::Tools::Spec;

use Data::Random qw( rand_date );
use Time::Piece;

describe 'Time tests' => sub {
    my ($min_date, $max_date, $case, $today);

    before_all 'Get today' => sub { $today = localtime };

    before_each 'Create Time::Piece objects' => sub {
        $min_date = Time::Piece->strptime( $case->{min}, '%Y-%m-%d' );
        $max_date = Time::Piece->strptime( $case->{max}, '%Y-%m-%d' );
    };

    case 'max now' => sub {
        $case = {
            args => { min => '2014-07-11', max => 'now' },
            min => '2014-07-11',
            max => $today->ymd,
        };
    };

    case 'min now' => sub {
        $case = {
            args => { min => 'now' },
            min => $today->ymd,
            max => $today->add_years(1)->ymd,
        };
    };

    case 'min && max' => sub {
        $case = {
            args => { min => '2015-3-1', max => '2015-5-10' },
            min => '2015-03-01',
            max => '2015-05-10',
        };
    };

    case 'min' => sub {
        $case = {
            args => { min => '1979-08-02' },
            min => '1979-08-02',
            max => '1980-08-02',
        };
    };

    case 'no args' => sub {
        $case = {
            args => {},
            min  => $today->ymd,
            max  => $today->add_years(1)->ymd,
        };
    };

    tests 'Random date is between boundaries' => sub {
        for (0 .. 999) {
            my $rand_date = rand_date( %{$case->{args}} );

            like $rand_date, qr/^\d{4}-\d{2}-\d{2}$/, 'rand_date format';

            my $result = Time::Piece->strptime( $rand_date, '%Y-%m-%d' );

            cmp_ok $result, '>=', $min_date, 'rand_date >= minimum';
            cmp_ok $result, '<=', $max_date, 'rand_date <= maximum';
        }
    };
};

done_testing;

