use Test2::V0;
use Test2::Tools::Spec;

use Data::Random qw( rand_enum );

describe 'Single random element' => sub {
    my ($set);

    case 'single element' => sub { $set = ['A'];       };
    case 'two elements'   => sub { $set = ['A', 'B']   };
    case 'roman alphabet' => sub { $set = ['A' .. 'Z'] };

    describe 'Get an element from a list' => sub {
        my ($valid);

        before_all 'Hash valid elements' => sub {
            $valid = { map { $_ => 1 } @{$set} };
        };

        it 'Returns a single valid element' => sub {
            my @elems = rand_enum( set => $set );
            is scalar(@elems), 1, 'Got a single element';
            like $valid, { map { $_ => 1 } @elems }, 'Got a valid element';
        };

        it 'Assumes set when only argument is an array ref' => sub {
            my @elems = rand_enum( $set );
            is scalar(@elems), 1, 'Got a single element';
            like $valid, { map { $_ => 1 } @elems }, 'Got a valid element';
        };
    };
};

describe 'Edge cases' => sub {
    my $elem;

    it 'Returns undef with an empty set' => sub {
        is rand_enum( set => [] ), U();
    };

    it 'Dies if set is not an array reference' => sub {
        like dies { rand_enum( set => {} ) }, qr/Not an ARRAY reference/;
    };

    it 'Requires a set' => sub {
        like warning { $elem = rand_enum() }, qr/set array is not defined/;
        is $elem, U(), 'Returns undefined';
    };

    it 'Only assumes set when given a single argument array reference' => sub {
        like warning { $elem = rand_enum( [], 'foo' ) },
            qr/set array is not defined/;
        is $elem, U(), 'Returns undefined';

        like warnings { $elem = rand_enum( {} ) },
            [
                qr/even-sized list expected/,
                qr/set array is not defined/,
            ];
        is $elem, U(), 'Returns undefined';
    };
};

done_testing;
