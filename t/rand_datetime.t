use Test2::V0;
use Test2::Tools::Spec;

BEGIN { use Test::MockTime qw( set_fixed_time ); }

use Data::Random qw( rand_datetime );
use Time::Piece;

describe 'Bad input' => sub {
    it 'Warns if min date is later than max date' => sub {
        like warning
            { rand_datetime( max => '2010-01-01', min => '2020-01-01' ) },
            qr/later than/;
    };
};

describe 'Time boundaries' => sub {
    my ($min_date, $max_date, $case);

    before_case 'Set fixed time' => sub {
        set_fixed_time('1987-12-18T00:00:00Z');
    };

    before_each 'Create Time::Piece objects' => sub {
        $min_date = Time::Piece->strptime( $case->{min}, '%Y-%m-%d %H:%M:%S' );
        $max_date = Time::Piece->strptime( $case->{max}, '%Y-%m-%d %H:%M:%S' );

        srand(12345); # Generates 2018-04-28 00:11:39
    };

    case 'max now' => sub {
        my $today = localtime;
        $case = {
            args => { min => '1984-07-11 4:00:00', max => 'now' },
            min => '1984-07-11 4:00:00',
            max => $today->ymd . ' ' . $today->hms,
        };
    };

    case 'min now' => sub {
        set_fixed_time('2020-12-18T00:00:00Z');
        my $today = localtime;
        $case = {
            args => { min => 'now' },
            min => $today->ymd . ' ' . $today->hms,
            max => $today->add_years(1)->ymd . ' ' . $today->hms,
        };
    };

    case 'min && max' => sub {
        set_fixed_time('2001-12-18T00:00:00Z');
        my $today = localtime;
        my $min = $today->ymd . ' ' . $today->hms;
        my $max = $today->add_years(1)->ymd . ' ' . $today->hms;
        $case = {
            args => { min => $min, max => $max },
            min => $min,
            max => $max,
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
        my $today = localtime;
        $case = {
            args => {},
            min  => $today->ymd . ' ' . $today->hms,
            max  => $today->add_years(1)->ymd .' ' . $today->hms,
        };
    };

    tests 'Random date is between boundaries' => sub {
        my $rand_datetime = rand_datetime( %{$case->{args}} );

        like $rand_datetime,
            qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/,
            'rand_datetime format';

        my $result = Time::Piece
            ->strptime( $rand_datetime, '%Y-%m-%d %H:%M:%S' );

        note $rand_datetime;
        cmp_ok $rand_datetime, 'ne', '2018-04-28 00:11:39', 'Date was changed';
        cmp_ok $result, '>=', $min_date, "$rand_datetime >= $case->{min}";
        cmp_ok $result, '<=', $max_date, "$rand_datetime <= $case->{max}";
    };
};

done_testing;
