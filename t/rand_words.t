use Test2::V0;
use Test2::Tools::Spec;
use Test2::Plugin::DieOnFail;

use Data::Random qw( rand_words );
use File::Temp;

describe 'Single random word' => sub {
    my ($valid, $num_words, $wordlist);

    before_all 'Prepare data' => sub {
        my $fh;

        $num_words = 26;
        ($fh, $wordlist) = File::Temp::tempfile();

        foreach ( 'A' .. 'Z' ) {
            print $fh "$_\n";
            $valid->{$_} = 1;
        }

        close($fh);
    };

    before_each 'Set seed' => sub {  srand 123456 };

    it 'Should return one word by default' => sub {
        foreach (1 .. $num_words) {
            my @words = rand_words( wordlist => $wordlist );
            is scalar(@words), 1, 'Got a single word';
            ok exists $valid->{ $words[0] }, 'Is a valid word';
        }
    };

    it 'Can specify return size' => sub {
        foreach my $size (1 .. $num_words) {
            my @words = rand_words( wordlist => $wordlist, size => $size );
            is scalar(@words), $size, 'Got right number of words';
            like $valid, { map { $_ => 1 } @words }, 'All words are valid';
        }
    };

    it 'Can specify min and maximum for return list' => sub {
        foreach my $size (1 .. $num_words) {
            my $min = $size - 1;
            my @words = rand_words(
                wordlist => $wordlist,
                min      => $min,
                max      => $num_words,
            );

            cmp_ok scalar(@words), '>=', $min, 'Got right number of words';
            like $valid, { map { $_ => 1 } @words }, 'All words are valid';
        }
    };

    it 'Ignores min and max if size is set' => sub {
        foreach my $size (1 .. $num_words) {
            my @words = rand_words(
                wordlist => $wordlist,
                size     => $size,
                min      => $size - 1,
                max      => $num_words,
            );

            is scalar(@words), $size, 'Got right number of words';
            like $valid, { map { $_ => 1 } @words }, 'All words are valid';
        }
    };

    it 'Can keep order of words' => sub {
        foreach (1.. $num_words) {
            my @words = rand_words(
                wordlist => $wordlist,
                size    => 2,
                shuffle => 0,
            );

            is scalar(@words), 2, 'Got right number of words';
            cmp_ok $words[0], 'lt', $words[1], 'Words are ordered';
        }
    };

    it 'Can use default wordlist' => sub {
        my @words = rand_words(
            size    => 2,
            shuffle => 0,
        );

        is \@words, [qw( pickings unanalyzable )], 'Got right words';
    };

    it 'Returns array reference in scalar context' => sub {
        my $words = rand_words(
            size    => 2,
            shuffle => 0,
        );

        is $words, [qw( pickings unanalyzable )], 'Got right words';
    };

    it 'Can use existing WordList object' => sub {
        require Data::Random::WordList;

        my @words = rand_words(
            wordlist => Data::Random::WordList->new( wordlist => $wordlist ),
            size    => 2,
            shuffle => 0,
        );

        is scalar(@words), 2, 'Got right number of words';
        cmp_ok $words[0], 'lt', $words[1], 'Words are ordered';
    };
};

done_testing;
