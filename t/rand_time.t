use strict;
use Test;

BEGIN { plan tests => 5 }

use lib qw(..);
use Data::Random qw( rand_time );

# Test default w/ no params
{
    my $pass = 1;

    my $max_secs = 3600;    # 86400

    my $i = 0;
    while ( $pass && $i < $max_secs ) {
        my $time = rand_time();

        $pass = 0 unless _to_secs($time);

        $i++;
    }

    ok($pass);
}

# Test min option
{
    my $pass = 1;

    my $max_secs = 3600;    # 72000

    my $i = 0;
    while ( $pass && $i < $max_secs ) {
        my $time = rand_time( min => '4:0:0' );

        $pass = 0 unless _to_secs($time) >= 14400;

        $i++;
    }

    ok($pass);
}

# Test max option
{
    my $pass = 1;

    my $max_secs = 3600;    # 14400

    my $i = 0;
    while ( $pass && $i < $max_secs ) {
        my $time = rand_time( max => '4:0:0' );

        $pass = 0 unless _to_secs($time) <= 14400;

        $i++;
    }

    ok($pass);
}

# Test min + max options
{
    my $pass = 1;

    my $max_secs = 3600;

    my $i = 0;
    while ( $pass && $i < $max_secs ) {
        my $time = rand_time( min => '9:0:0', max => '10:0:0' );

        my $secs = _to_secs($time);

        $pass = 0 unless $secs >= 32400 && $secs <= 36000;

        $i++;
    }

    ok($pass);
}

# Test min + max options using "now"
{
    my $pass = 1;

    my $time = rand_time( min => 'now', max => 'now' );

    my ( $hour, $min, $sec ) = ( localtime() )[ 2, 1, 0 ];

    my ( $new_hour, $new_min, $new_sec ) = split ( /\:/, $time );

    $pass = 0 unless $new_hour == $hour && $new_min == $min && $new_sec == $sec;

    ok($pass);
}

sub _to_secs {
    my $time = shift;

    my ( $hour, $min, $sec ) = split ( /\:/, $time );

    return if ( $hour > 23 ) || ( $hour < 0 );
    return if ( $min > 59 )  || ( $min < 0 );
    return if ( $sec > 59 )  || ( $sec < 0 );

    return $hour * 3600 + $min * 60 + $sec;
}
