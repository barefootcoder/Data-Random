use strict;
use Test;

BEGIN { plan tests => 5 }

use lib qw(..);
use Data::Random qw( rand_words );
use File::Spec;

use vars qw( $wordlist );

$wordlist = File::Spec->tmpdir() . '/Data_Random_' . time() . '.tmp';

open( FILE, ">$wordlist" );
foreach ( 'A' .. 'Z' ) {
    print FILE "$_\n";
}
close(FILE);

my %valid_words;
@valid_words{ 'A' .. 'Z' } = ();

my $num_words = 26;

# Test default w/ no params -- should return one entry
{
    my $pass = 1;

    my $i = 0;
    while ( $pass && $i < $num_words ) {
        my @words = rand_words( wordlist => $wordlist );

        $pass = 0 unless ( @words == 1 && exists( $valid_words{ $words[0] } ) );

        $i++;
    }

    ok($pass);
}

# Test size option
{
    my $pass = 1;

    my $i = 0;
    while ( $pass && $i < $num_words ) {
        my @words = rand_words( wordlist => $wordlist, size => $i + 1 );

        $pass = 0 unless @words == ( $i + 1 );

        foreach (@words) {
            $pass = 0 unless exists( $valid_words{$_} );
        }

        $i++;
    }

    ok($pass);
}

# Test max/min option
{
    my $pass = 1;

    my $i = 0;
    while ( $pass && $i < $num_words ) {
        my @words =
          rand_words( wordlist => $wordlist, min => $i, max => $num_words );

        $pass = 0 unless ( @words >= $i && @words <= $num_words );

        foreach (@words) {
            $pass = 0 unless exists( $valid_words{$_} );
        }

        $i++;
    }

    ok($pass);
}

# Test size w/ min/max set
{
    my $pass = 1;

    my $i = 0;
    while ( $pass && $i < $num_words ) {
        my @words = rand_words(
            wordlist => $wordlist,
            size     => $i + 1,
            min      => $i,
            max      => $num_words
        );

        $pass = 0 unless @words == ( $i + 1 );

        foreach (@words) {
            $pass = 0 unless exists( $valid_words{$_} );
        }

        $i++;
    }

    ok($pass);
}

# Test w/ shuffle set to 0
{
    my $pass = 1;

    my $i = 0;
    while ( $pass && $i < $num_words ) {
        my @words =
          rand_words( wordlist => $wordlist, size => 2, shuffle => 0 );

        $pass = 0 unless ( @words == 2 && !( $words[0] gt $words[1] ) );

        $i++;
    }

    ok($pass);
}

END {
    unlink($wordlist);
}
