use Test2::V0 -srand => 123456;

use Test2::Tools::Spec;

use Data::Random qw( rand_chars);

describe 'Get random characters' => sub {
    my (%charsets, $set);

    before_all 'Prepare data' => sub {
        %charsets = (
            loweralpha => [ 'a' .. 'z' ],
            upperalpha => [ 'A' .. 'Z' ],
            numeric    => [ 0 .. 9 ],
            misc       => ['#', ',', qw#
                ~ ! @ $ % ^ & * _ + = - | : " < > ? / . ' ; \ ` { } [ ] ( )
            #],
        );

        $charsets{alpha} =
            [ map { @{ $charsets{$_} } } qw( upperalpha loweralpha ) ];

        $charsets{alphanumeric} =
            [ map { @{ $charsets{$_} } } qw( alpha numeric ) ];

        $charsets{all} = [
            sort keys %{
                { map { $_ => 1 } map { @{$_} } values %charsets }
            }
        ];

    };

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

        around_each 'consolidate tests' => sub {
            my $cont = shift;
            $result = 1;
            $cont->();
            ok $result;
        };

        it 'Should return one character by default' => sub {
            foreach (1 .. $num_chars) {
                my @chars = rand_chars( set => $set );

                $result = quiet_is
                    scalar(@chars), 1, 'Got a single char';

                $result = quiet_like
                    $valid, { map { $_ => 1 } @chars }, 'Got a valid char';

                last unless $result;
            }
        };

        it 'Can specify return size' => sub {
            foreach my $size (1 .. $num_chars) {
                my @chars = rand_chars( set => $set, size => $size );

                $result = quiet_is
                    scalar(@chars), $size, 'Got right number of chars';

                $result = quiet_like
                    $valid, { map { $_ => 1 } @chars }, 'All characters are valid';

                last unless $result;
            }
        };

        it 'Can specify min and maximum for return list' => sub {
            foreach my $size (1 .. $num_chars) {
                my $min = $size - 1;
                my @chars = rand_chars(
                    set => $set,
                    min      => $min,
                    max      => $num_chars,
                );

                $result = quiet_gte
                    scalar(@chars), $min, 'Got right number of chars';

                $result = quiet_like
                    $valid, { map { $_ => 1 } @chars }, 'All characters are valid';

                last unless $result;
            }
        };

        it 'Ignores min and max if size is set' => sub {
            foreach my $size (1 .. $num_chars) {
                my @chars = rand_chars(
                    set => $set,
                    size     => $size,
                    min      => $size - 1,
                    max      => $num_chars,
                );

                $result = quiet_is
                    scalar(@chars), $size, 'Got right number of chars';

                $result = quiet_like
                    $valid, { map { $_ => 1 } @chars }, 'All characters are valid';

                last unless $result;
            }
        };

        it 'Can keep order of chars' => sub {
            foreach (1.. $num_chars) {
                my @chars = rand_chars(
                    set => $set,
                    size    => 2,
                    shuffle => 0,
                );

                $result = quiet_is
                    scalar(@chars), 2, 'Got right number of chars';

                $result = quiet_ok
                    _are_ordered( $set, @chars ), 'Characters are ordered';

                last unless $result;
            }
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
