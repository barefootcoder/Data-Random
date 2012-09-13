use strict;
use Test::More;

BEGIN { plan tests => 5 }

use lib qw(..);
use Data::Random qw( rand_datetime );

# Try to load Date::Calc 
eval q{ use Date::Calc };

SKIP: {

    # If the module cannot be loaded, skip tests
    skip('Date::Calc not installed', 5) if $@;

    # Get today's date
    my ( $year, $month, $day ) = Date::Calc::Today();

    # Test default w/ no params -- should return a date between today and 1 year from now
    {
        my $pass = 1;

        my $max_days =
          Date::Calc::Delta_Days( $year, $month, $day,
            Date::Calc::Add_Delta_YMD( $year, $month, $day, 1, 0, 0 ) );

        my $i = 0;
        while ( $pass && $i < $max_days ) {
            my $date = rand_datetime();

            my $delta =
              Date::Calc::Delta_Days( $year, $month, $day,
                ( $date =~ /^(\d+)-(\d+)-(\d+)/ ) );

            $pass = 0
              unless $delta >= 0 && $delta <= $max_days
              && defined _to_secs( ( split ( / /, $date ) )[1] );

            $i++;
        }

        ok($pass);
    }

    # Test min option
    {
        my $pass = 1;

        my $max_days = Date::Calc::Delta_Days( 1978, 9, 21, 1979, 9, 21 );

        my $i = 0;
        while ( $pass && $i < $max_days ) {
            my $date = rand_datetime( min => '1978-9-21 4:0:0' );

            my $delta =
              Date::Calc::Delta_Days( 1978, 9, 21,
                ( $date =~ /^(\d+)-(\d+)-(\d+)/ ) );

            $pass = 0
              unless $delta >= 0 && $delta <= $max_days
              && defined _to_secs( ( split ( / /, $date ) )[1] );

            $i++;
        }

        ok($pass);
    }

    # Test max option
    {
        my $pass = 1;

        my $max_days =
          Date::Calc::Delta_Days( $year, $month, $day,
            Date::Calc::Add_Delta_YMD( $year, $month, $day, 1, 0, 0 ) );

        my $i = 0;
        while ( $pass && $i < $max_days ) {
            my $date =
              rand_datetime( max =>
                join ( '-',
                    Date::Calc::Add_Delta_YMD( $year, $month, $day, 1, 0, 0 ) )
                . ' 0:0:0' );

            my $delta =
              Date::Calc::Delta_Days( $year, $month, $day,
                ( $date =~ /^(\d+)-(\d+)-(\d+)/ ) );

            $pass = 0
              unless $delta >= 0 && $delta <= $max_days
              && defined _to_secs( ( split ( / /, $date ) )[1] );

            $i++;
        }

        ok($pass);
    }

    # Test min + max options
    {
        my $pass = 1;

        my $max_days =
          Date::Calc::Delta_Days( $year, $month, $day,
            Date::Calc::Add_Delta_YMD( $year, $month, $day, 1, 0, 0 ) );

        my $i = 0;
        while ( $pass && $i < $max_days ) {
            my $date = rand_datetime(
                min => "$year-$month-$day 12:0:0",
                max =>
                join ( '-',
                    Date::Calc::Add_Delta_YMD( $year, $month, $day, 1, 0, 0 ) )
                . ' 12:0:0'
            );

            my $delta =
              Date::Calc::Delta_Days( $year, $month, $day,
                ( $date =~ /^(\d+)-(\d+)-(\d+)/ ) );

            $pass = 0
              unless $delta >= 0 && $delta <= $max_days
              && defined _to_secs( ( split ( / /, $date ) )[1] );

            $i++;
        }

        ok($pass);
    }

    # Test min + max options using "now"
    {
        my $pass = 1;

        my $date = rand_datetime( min => 'now', max => 'now' );

        my ( $new_year, $new_month, $new_day ) = ( $date =~ /^(\d+)-(\d+)-(\d+)/ );

        $pass = 0
          unless $new_year == $year && $new_month == $month && $new_day == $day
          && defined _to_secs( ( split ( / /, $date ) )[1] );

        ok($pass);
    }
}

sub _to_secs {
    my $time = shift;

    my ( $hour, $min, $sec ) = split ( /\:/, $time );

    return undef if ( $hour > 23 ) || ( $hour < 0 );
    return undef if ( $min > 59 )  || ( $min < 0 );
    return undef if ( $sec > 59 )  || ( $sec < 0 );

    return $hour * 3600 + $min * 60 + $sec;
}
