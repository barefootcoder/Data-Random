use Test2::V0 -srand => 123456;
use Test2::Tools::Spec;

use Data::Random qw( rand_enum );

describe 'Single random element' => sub {
    my ($set);

    case 'empty set'      => sub { $set = []           };
    case 'single element' => sub { $set = ['A'];       };
    case 'two elements'   => sub { $set = ['A', 'B']   };
    case 'roman alphabet' => sub { $set = ['A' .. 'Z'] };

    describe 'Get an element from a list' => sub {
        my ($valid);

        before_all 'Hash valid elements' => sub {
            $valid = { map { $_ => 1 } @{$set} };
        };

        tests 'Random element is valid' => sub {
            my $result = 1;
            foreach (@{$set}) {
                my @elems = rand_enum( set => $set );

                unless (scalar(@elems) == 1) {
                    note 'Did not get a single element';
                    $result = 0;
                    last;
                }

                unless (exists $valid->{ $elems[0] }) {
                    note 'Did not get a valid element';
                    $result = 0;
                    last;
                }
            }
            ok $result;
        };

        tests 'Can omit "set" if using only an array ref' => sub {
            my $result = 1;
            if (@{$set}) {
                my $char = rand_enum($set);

                unless ($char) {
                    note 'Did not return a character';
                    $result = 0;
                    last;
                }

                unless (exists $valid->{ $char }) {
                    note 'Did not return a valid character';
                    $result = 0;
                    last;
                }
            }
            ok $result;
        };
    };
};

done_testing;
