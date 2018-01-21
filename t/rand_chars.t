use Test2::V0;

use Test2::Tools::Spec;

use Data::Random qw( rand_chars);

describe 'Context sensitivity' => sub {
    my %args = ( set => [ 'A' .. 'Z' ], size => 5 );

    before_each 'Seed' => sub { srand(123456); };

    it 'Returns an array in list context' => sub {
        is [ rand_chars( %args ) ], [qw( R Y Q B F )];
    };

    it 'Returns a concatenated string in scalar context' => sub {
        is +rand_chars( %args ), 'RYQBF';
    };
};

describe 'Bad input' => sub {
    it 'Assumes an empty set if it is unknown' => sub {
        my @ret = rand_chars( set => 'some name', min => 0 );
        is \@ret, [];
    };
};

describe 'Get random characters' => sub {
    my (%charsets, $set, $size, $seed);

    before_all 'Prepare data' => sub {
        %charsets = (
            loweralpha => [ 'a' .. 'z' ],
            upperalpha => [ 'A' .. 'Z' ],
            numeric    => [ 0 .. 9 ],
            misc       => ['#', ',', qw#
                ~ ! @ $ % ^ & * _ + = - | : " < > ? / . ' ; \ ` { } [ ] ( )
            #],
        );

        $charsets{all} = [ sort map { @{$_} } values %charsets ];

        $charsets{char} = $charsets{misc};

        $charsets{alpha} =
            [ map { @{ $charsets{$_} } } qw( upperalpha loweralpha ) ];

        $charsets{alphanumeric} =
            [ map { @{ $charsets{$_} } } qw( alpha numeric ) ];

        $size = 3;
        $seed = 666;
    };

    before_each 'Random seed' => sub {
        srand($seed);
    };

    describe 'Explicit sets' => sub {

        case 'alpha'      => sub { $set = $charsets{alpha}      };
        case 'numeric'    => sub { $set = $charsets{numeric}    };
        case 'misc'       => sub { $set = $charsets{misc}       };
        case 'upperlapha' => sub { $set = $charsets{upperalpha} };
        case 'lowerlapha' => sub { $set = $charsets{loweralpha} };
        case 'all'        => sub { $set = $charsets{all}        };

        describe 'Foo' => sub {
            my ($valid, $num_chars, $result);

            before_all 'Hash valid elements' => sub {
                $valid     = { map { $_ => 1 } @{$set} };
                $num_chars = scalar @{$set};
            };

            it 'Returns one character by default' => sub {
                my @chars = rand_chars( set => $set );
                is scalar(@chars), 1, 'Got a single char';
                like $valid, { map { $_ => 1 } @chars }, 'Got a valid char';
            };

            it 'Can specify return size' => sub {
                my @chars = rand_chars( set => $set, size => $size );
                is scalar(@chars), $size, 'Got right number of chars';
                like $valid, { map { $_ => 1 } @chars }, 'All characters are valid';
            };

            it 'Can specify min and maximum for return list' => sub {
                my $max = int( scalar(@{$set}) / 2 ) + 1;
                my @baseline;

                do {
                    $max--;
                    srand($seed);
                    @baseline = rand_chars( set => $set, max => $max );
                } until $max < 1 or scalar(@baseline) < $max;

                if ($max < 1) {
                    ok 1, 'Abandoned test, because of bad seed';
                    return;
                };

                note 'Got ' . scalar @baseline . ' elements without min';

                srand($seed);
                my $min = scalar(@baseline) + 1;
                my @chars = rand_chars( set => $set, min => $min, max => $max );

                note 'Got ' . scalar @chars . ' elements with min';

                cmp_ok scalar(@chars), '>=', $min, 'Min affected rand_chars outcome';
                like $valid, { map { $_ => 1 } @chars }, 'All characters are valid';
            };

            it 'Ignores min and max if size is set' => sub {
                my @chars = rand_chars(
                    set  => $set,
                    size => $size * 2,
                    max  => $size,
                );

                is scalar(@chars), $size * 2, 'Ignored max';
                like $valid, { map { $_ => 1 } @chars }, 'All characters are valid';

                @chars = rand_chars(
                    set  => $set,
                    size => $size,
                    min  => $size * 2,
                );

                is scalar(@chars), $size, 'Ignored min';
                like $valid, { map { $_ => 1 } @chars }, 'All characters are valid';
            };

            it 'Can keep order of chars' => sub {
                my @chars = rand_chars(
                    set     => $set,
                    size    => 2,
                    shuffle => 0,
                );

                is scalar(@chars), 2, 'Got right number of chars';
                ok _are_ordered( $set, @chars ), 'Characters are ordered';
            };
        };
    };

    describe 'Sets by name' => sub {
        case 'alpha'        => sub { $set = 'alpha'        };
        case 'numeric'      => sub { $set = 'numeric'      };
        case 'alphanumeric' => sub { $set = 'alphanumeric' };
        case 'misc'         => sub { $set = 'misc'         };
        case 'char'         => sub { $set = 'char'         };
        case 'upperlapha'   => sub { $set = 'upperalpha'   };
        case 'lowerlapha'   => sub { $set = 'loweralpha'   };
        case 'all'          => sub { $set = 'all'          };

        it 'Gets characters from the correct set' => sub {
            my $valid = { map { $_ => 1 } @{$charsets{$set}} };
            my @chars = rand_chars( set => $set, size => 10 );
            like $valid, { map { $_ => 1 } @chars }, 'All characters are valid';
        };
    };
};

done_testing;

sub _are_ordered {
    my ( $set, @chars ) = @_;
    return _get_index($set, $chars[0]) < _get_index($set, $chars[1]);
}

sub _get_index {
    my ( $set, $char ) = @_;
    my $i = 0;
    $i++ while $set->[$i] ne $char && $i < @{ $set };
    $i;
}
