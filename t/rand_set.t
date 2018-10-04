use Test2::V0 -srand => 123456;
use Test2::Tools::Spec;
use Test2::Plugin::DieOnFail;

use Data::Random qw( rand_set );

describe 'Get random elements' => sub {
    my ($set);

    case 'empty set'      => sub { $set = []           };
    case 'single element' => sub { $set = ['A'];       };
    case 'two elements'   => sub { $set = ['A', 'B']   };
    case 'roman alphabet' => sub { $set = ['A' .. 'Z'] };

    describe 'Get elements from a list' => sub {
        my ($valid);

        before_all 'Hash valid elements' => sub {
            $valid = { map { $_ => 1 } @{$set} };
        };

        it 'Defaults to returning a single element' => sub {
            foreach (@{$set}) {
                my @elems = rand_set( set => $set );
                is scalar(@elems), 1, 'Got a single element';
                ok exists $valid->{ $elems[0] }, 'Is a valid element';
            }
            ok 1, 'pass';
        };

        it 'Can return more elements with size parameter' => sub {
            foreach my $size (1 .. scalar @{$set}) {
                my @elems = rand_set( set => $set, size => $size );
                is scalar(@elems), $size, 'Got right number of elements';
                like $valid, { map { $_ => 1 } @elems }, 'All elements are valid';
            }
            ok 1, 'pass';
        };

        it 'Can specify a minimum and a maximum for return size' => sub {
            foreach my $size (1 .. scalar @{$set}) {
                my $min = $size - 1;
                my @elems = rand_set(
                    set => $set,
                    min => $min,
                    max => scalar(@{$set}),
                );

                cmp_ok scalar(@elems), '>=', $min,
                    'Got right number of elements';
                like $valid, { map { $_ => 1 } @elems }, 'All elements are valid';
            }
            ok 1, 'pass';
        };

        it 'Ignores min and max if size is set' => sub {
            foreach my $size (1 .. scalar @{$set}) {
                my @elems = rand_set(
                    set  => $set,
                    size => $size,
                    min  => $size - 1,
                    max  => scalar(@{$set}),
                );

                is scalar(@elems), $size, 'Got right number of elements';
                like $valid, { map { $_ => 1 } @elems }, 'All elements are valid';
            }
            ok 1, 'pass';
        };

        it 'Can keep order of elements' => sub {
            foreach (@{$set}) {
                last unless scalar(@{$set}) >= 2;

                my @elems = rand_set(
                    set     => $set,
                    size    => 2,
                    shuffle => 0,
                );

                is scalar(@elems), 2, 'Got right number of elements';
                cmp_ok
                    _get_index($set, $elems[0]), '<',
                    _get_index($set, $elems[1]), 'Elements are ordered';
            }
            ok 1, 'pass';
        };

    };

};

describe 'Return by calling context' => sub {
    before_each 'Seed' => sub { srand 1234 };

    it 'Returns array reference in scalar context' => sub {
        my $elems = rand_set( set => ['a' .. 'z'], size => 5, shuffle => 0 );
        is $elems, [qw( f h i t z )];
    };

    it 'Returns array in array context' => sub {
        my @elems = rand_set( set => ['a' .. 'z'], size => 5, shuffle => 0 );
        is \@elems, [qw( f h i t z )];
    };
};

done_testing;

sub _get_index {
    my ( $set, $char ) = @_;
    my $i = 0;
    $i++ while $set->[$i] ne $char && $i < @{ $set };
    $i;
}
