use Test2::V0;
use Test2::Tools::Spec;

BEGIN { use Test::MockTime qw( set_fixed_time ); }

use Data::Random qw( rand_date );
use Time::Piece;

describe 'Bad input' => sub {
    it 'Warns if min date is later than max date' => sub {
        like warning
            { rand_date( max => '2010-01-01', min => '2020-01-01' ) },
            qr/later than/;
    };
};

describe 'Time boundaries' => sub {
    my ($min_date, $max_date, $case);

    before_case 'Set fixed time' => sub {
        set_fixed_time('1987-12-18T00:00:00Z');
    };

    before_each 'Create Time::Piece objects' => sub {
        $min_date = Time::Piece->strptime( $case->{min}, '%Y-%m-%d' );
        $max_date = Time::Piece->strptime( $case->{max}, '%Y-%m-%d' );

        srand(12345); # Generates 2018-04-27
    };

    case 'max now' => sub {
        my $today = localtime;
        $case = {
            args => { min => '1986-12-18', max => 'now' },
            min => $today->add_years(-1)->ymd,
            max => $today->ymd,
        };
    };

    case 'min now' => sub {
        set_fixed_time('2020-12-18T00:00:00Z');
        my $today = localtime;
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
        my $today = localtime;
        $case = {
            args => {},
            min  => $today->ymd,
            max  => $today->add_years(1)->ymd,
        };
    };

    tests 'Random date is between boundaries' => sub {
        my $rand_date = rand_date( %{$case->{args}} );

        like $rand_date, qr/^\d{4}-\d{2}-\d{2}$/, 'rand_date format';

        my $result = Time::Piece->strptime( $rand_date, '%Y-%m-%d' );

        note $rand_date;
        cmp_ok $result, '>=', $min_date, 'rand_date >= minimum';
        cmp_ok $result, '<=', $max_date, 'rand_date <= maximum';
    };
};

done_testing;
