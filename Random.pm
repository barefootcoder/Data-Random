################################################################################
# Data::Random
#
# A module used to generate random data.
#
# Author: Adekunle Olonoh
#   Date: October 2000
################################################################################


package Data::Random;


################################################################################
# - Modules and Libraries
################################################################################
require 5.005_62;

use lib qw(..);
use Data::Random::WordList;

require Exporter;


################################################################################
# - Global Constants and Variables
################################################################################
use vars qw(
    @ISA
    %EXPORT_TAGS
    @EXPORT_OK
    @EXPORT
);

@ISA = qw(Exporter);

%EXPORT_TAGS = (
    'all' => [ qw(
        rand_words
        rand_chars
        rand_set
        rand_enum
        rand_date
        rand_time
        rand_datetime
    ) ]
);

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
@EXPORT = qw();

$Data::Random::VERSION = '0.01';


################################################################################
# - Subroutines
################################################################################


################################################################################
# rand_words()
################################################################################
sub rand_words {
    # Get the options hash
    my %options = @_;
    
    # Make sure the wordlist param was specified
    die 'a wordlist must be specified' if !$options{'wordlist'};
    
    # Initialize max and min vars
    $options{'min'} ||= 1;
    $options{'max'} ||= 1;
        
    # Make sure the max and min vars are OK
    die 'min value cannot be larger than max value' if $options{'min'} > $options{'max'};
    die 'min value must be a positive integer' if $options{'min'} < 0 || $options{'min'} != int($options{'min'});
    die 'max value must be a positive integer' if $options{'max'} < 0 || $options{'max'} != int($options{'max'});
    
    # Initialize the size var
    $options{'size'} ||= int(rand($options{'max'} - $options{'min'} + 1)) + $options{'min'};
    
    # Make sure the size var is OK
    die 'size value must be a positive integer' if $options{'size'} < 0 || $options{'size'} != int($options{'size'});
    
    # Initialize the shuffle flag
    $options{'shuffle'} = $options{'shuffle'} ? 1 : 0;
    
    my $wl;
    my $close_wl = 1;
    
    # Check for a pre-existing wordlist object
    if (ref($options{'wordlist'})) {
        $wl = $options{'wordlist'};
        $close_wl = 0;
    }
    else {
        # Create a new wordlist object    
        $wl = new Data::Random::WordList( wordlist => $options{'wordlist'} );
    }
    
    # Get the random words
    my $rand_words = $wl->get_words($options{'size'});
    
    # Close the word list
    $wl->close() if $close_wl;

    # Shuffle the words around
    shuffle($rand_words) if $options{'shuffle'};

    # Return an array or an array reference, depending on the context in which the sub was called
    if (wantarray()) {
        return @$rand_words;
    }
    else {
        return $rand_words;
    }
}


################################################################################
# rand_chars()
################################################################################
sub rand_chars {
    # Get the options hash
    my %options = @_;
    
    # Build named character sets if one wasn't supplied
    if (ref($options{'set'}) ne 'ARRAY') {
        my @charset = ();
        
        if ($options{'set'} eq 'all') {
            @charset = (0..9, 'a'..'z', 'A'..'Z', '#', ',', qw(~ ! @ $ % ^ & * ( ) _ + = - { } | : " < > ? / . ' ; ] [ \ `));
        }
        elsif ($options{'set'} eq 'alpha') {
            @charset = ('a'..'z', 'A'..'Z');
        }
        elsif ($options{'set'} eq 'upperalpha') {
            @charset = ('A'..'Z');
        }
        elsif ($options{'set'} eq 'loweralpha') {
            @charset = ('a'..'z');
        }
        elsif ($options{'set'} eq 'numeric') {
            @charset = (0..9);
        }
        elsif ($options{'set'} eq 'alphanumeric') {
            @charset = (0..9, 'a'..'z', 'A'..'Z');
        }
        elsif ($options{'set'} eq 'misc') {
            @charset = ('#', ',', qw(~ ! @ $ % ^ & * ( ) _ + = - { } | : " < > ? / . ' ; ] [ \ `));
        }
        
        $options{'set'} = \@charset;
    }
    
    return rand_set(%options);
}


################################################################################
# rand_set()
################################################################################
sub rand_set {
    # Get the options hash
    my %options = @_;
    
    # Make sure the set array was defined
    die 'set array is not defined' if !$options{'set'};
    
    my @set = @{$options{'set'}};
    my $set_length = scalar @set;
    
    # Initialize max and min vars
    $options{'min'} ||= 0;
    $options{'max'} ||= @set;

    # Make sure the max and min vars are OK
    die 'min value cannot be larger than max value' if $options{'min'} > $options{'max'};
    die 'min value must be a positive integer' if $options{'min'} < 0 || $options{'min'} != int($options{'min'});
    die 'max value must be a positive integer' if $options{'max'} < 0 || $options{'max'} != int($options{'max'});
    
    # Initialize the size var
    $options{'size'} ||= int(rand($options{'max'} - $options{'min'} + 1)) + $options{'min'};
    
    # Make sure the size var is OK
    die 'size value must be a positive integer' if $options{'size'} < 0 || $options{'size'} != int($options{'size'});
    die 'size value exceeds set size' if $options{'size'} > $set_length;
    
    # Initialize the shuffle flag
    $options{'shuffle'} = $options{'shuffle'} ? 1 : 0;
    
    # Get the random items
    my @results = ();
    for(my $i = 0; $i < $options{'size'}; $i++) {
        my $result = int(rand($set_length));

        push(@results, $set[$result]);
        splice(@set, $result, 1);
        $set_length--;
    }

    # Shuffle the items
    shuffle(\@results) if $options{'shuffle'};

    # Return an array or an array reference, depending on the context in which the sub was called
    if (wantarray()) {
        return @results;
    }
    else {
        return \@results;
    }
}


################################################################################
# rand_enum()
################################################################################
sub rand_enum {
    # Get the options hash
    my %options = @_;
    
    # Make sure the set array was defined
    die 'set array is not defined' if !$options{'set'};
   
    return $options{'set'}->[int(rand(@{$options{'set'}}))];
}


################################################################################
# rand_date()
################################################################################
sub rand_date {
    # Get the options hash
    my %options = @_;
    
    # use the Date::Calc module
    use Date::Calc;
    
    my ($min_year, $min_month, $min_day, $max_year, $max_month, $max_day);
    
    # Get today's date
    my ($year, $month, $day) = Date::Calc::Today();
    
    if ($options{'min'}) {
        if ($options{'min'} eq 'now') {
            ($min_year, $min_month, $min_day) = ($year, $month, $day);
        }
        else {
            ($min_year, $min_month, $min_day) = split(/\-/, $options{'min'});
        }
    }
    else {
        ($min_year, $min_month, $min_day) = ($year, $month, $day);
    }

    if ($options{'max'}) {
        if ($options{'max'} eq 'now') {
            ($max_year, $max_month, $max_day) = ($year, $month, $day);
        }
        else {
            ($max_year, $max_month, $max_day) = split(/\-/, $options{'max'});
        }
    }
    else {
        ($max_year, $max_month, $max_day) = Date::Calc::Add_Delta_YMD($min_year, $min_month, $min_day, 1, 0, 0);
    }    
        
    my $delta_days = Date::Calc::Delta_Days(
        $min_year, $min_month, $min_day,
        $max_year, $max_month, $max_day,
    );
    
    die 'max date is later than min date' if $delta_days < 0;
    
    $delta_days = int(rand($delta_days + 1));
    
    ($year, $month, $day) = Date::Calc::Add_Delta_Days($min_year, $min_month, $min_day, $delta_days);
    
    return sprintf("%04u-%02u-%02u", $year, $month, $day);
}


################################################################################
# rand_time()
################################################################################
sub rand_time {
    # Get the options hash
    my %options = @_;
    
    my ($min_hour, $min_min, $min_sec, $max_hour, $max_min, $max_sec);
    
    if ($options{'min'}) {
        if ($options{'min'} eq 'now') {
            # Get the current time
            my ($hour, $min, $sec) = (localtime())[2, 1, 0];
            
            ($min_hour, $min_min, $min_sec) = ($hour, $min, $sec);
        }
        else {
            ($min_hour, $min_min, $min_sec) = split(/\:/, $options{'min'});
            
            die 'minimum time is not in valid time format HH:MM:SS' if ($min_hour > 23) || ($min_hour < 0);
            die 'minimum time is not in valid time format HH:MM:SS' if ($min_min > 59) || ($min_min < 0);
            die 'minimum time is not in valid time format HH:MM:SS' if ($min_sec > 59) || ($min_sec < 0);
        }
    }
    else {
        ($min_hour, $min_min, $min_sec) = (0, 0, 0);
    }

    if ($options{'max'}) {
        if ($options{'max'} eq 'now') {
            # Get the current time
            my ($hour, $min, $sec) = (localtime())[2, 1, 0];
            
            ($max_hour, $max_min, $max_sec) = ($hour, $min, $sec);
        }
        else {
            ($max_hour, $max_min, $max_sec) = split(/\:/, $options{'max'});
                
            die 'maximum time is not in valid time format HH:MM:SS' if ($max_hour > 23) || ($max_hour < 0);
            die 'maximum time is not in valid time format HH:MM:SS' if ($max_min > 59) || ($max_min < 0);
            die 'maximum time is not in valid time format HH:MM:SS' if ($max_sec > 59) || ($max_sec < 0);
        }
    }
    else {
        ($max_hour, $max_min, $max_sec) = (23, 59, 59);
    }
       
    my $min_secs = $min_hour * 3600 + $min_min * 60 + $min_sec;
    my $max_secs = ($max_hour * 3600) + ($max_min * 60) + $max_sec;
    
    my $delta_secs = $max_secs - $min_secs;
    
    die 'min time is later than max time' if $delta_secs < 0;
    
    $delta_secs = int(rand($delta_secs + 1));
    
    my $result_secs = $min_secs + $delta_secs;

    my $hour = int($result_secs / 3600);
    my $min = int(($result_secs - ($hour * 3600)) / 60);
    my $sec = $result_secs % 60;
    
    return sprintf("%02u:%02u:%02u", $hour, $min, $sec);
}


################################################################################
# rand_datetime()
################################################################################
sub rand_datetime {
    # Get the options hash
    my %options = @_;
    
    # use the Date::Calc module
    use Date::Calc;
    
    my ($min_year, $min_month, $min_day, $min_hour, $min_min, $min_sec, $max_year, $max_month, $max_day, $max_hour, $max_min, $max_sec);
    
    # Get today's date
    my ($year, $month, $day, $hour, $min, $sec) = Date::Calc::Today_and_Now();
    
    if ($options{'min'}) {
        if ($options{'min'} eq 'now') {
            ($min_year, $min_month, $min_day, $min_hour, $min_min, $min_sec) = ($year, $month, $day, $hour, $min, $sec);
        }
        else {
            ($min_year, $min_month, $min_day, $min_hour, $min_min, $min_sec) = $options{'min'} =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)$/;
        }
    }
    else {
        ($min_year, $min_month, $min_day, $min_hour, $min_min, $min_sec) = ($year, $month, $day, 0, 0, 0);
    }

    if ($options{'max'}) {
        if ($options{'max'} eq 'now') {
            ($max_year, $max_month, $max_day, $max_hour, $max_min, $max_sec) = ($year, $month, $day, $hour, $min, $sec);
        }
        else {
            ($max_year, $max_month, $max_day, $max_hour, $max_min, $max_sec) = $options{'max'} =~ /^(\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)$/;
        }
    }
    else {
        ($max_year, $max_month, $max_day, $max_hour, $max_min, $max_sec) = (Date::Calc::Add_Delta_YMD($min_year, $min_month, $min_day, 1, 0, 0), 23, 59, 59);
    }    
    
    my ($delta_days, $delta_hours, $delta_mins, $delta_secs) = Date::Calc::Delta_DHMS(
        $min_year, $min_month, $min_day, $min_hour, $min_min, $min_sec,
        $max_year, $max_month, $max_day, $max_hour, $max_min, $max_sec,
    );
       
    die 'max date is later than min date' if ($delta_days < 0) || ($delta_hours < 0) || ($delta_mins < 0) || ($delta_secs < 0);
    
    $delta_secs = ($delta_days * 86400) + ($delta_hours * 3600) + ($delta_mins * 60) + $delta_secs;
    
    $delta_secs = int(rand($delta_secs + 1));
    
    ($year, $month, $day, $hour, $min, $sec) = Date::Calc::Add_Delta_DHMS($min_year, $min_month, $min_day, $min_hour, $min_min, $min_sec, 0, 0, 0, $delta_secs);
    
    return sprintf("%04u-%02u-%02u %02u:%02u:%02u", $year, $month, $day, $hour, $min, $sec);
}


################################################################################
# shuffle()
################################################################################
sub shuffle {
    my $array = shift;

    for (my $i = @$array - 1; $i >= 0; $i--) {
        my $j = int(rand($i + 1));

        @$array[$i, $j] = @$array[$j, $i] if $i != $j;
    }
}


1;


=head1 NAME

Data::Random - Perl module to generate random data


=head1 SYNOPSIS

  use Data::Random qw(:all);
  
  my @random_words = rand_words( wordlist => '/usr/dict/words', size => 10 );
    
  my @random_chars = rand_chars( set => 'all', min => 5, max => 8 );
  
  my @random_set = rand_set( set => \@set, size => 5 );
  
  my $random_enum = rand_enum( set => \@set );
  
  my $random_date = rand_date();
  
  my $random_time = rand_time();
    
  my $random_datetime = rand_datetime();


=head1 DESCRIPTION

A module used to generate random data.  Useful mostly for test programs.


=head1 METHODS

=head2 rand_words()

This returns a list of random words given a wordlist.  See below for possible parameters.

=over 4

=item *

wordlist - the path to the wordlist file.  A lot of systems have one at /usr/dict/words.  You can also optionally supply a Data::Random::WordList object to keep a persistent wordlist.

=item *

min - the minimum number of words to return.  The default is 1.

=item *

max - the maximum number of words to return.  The default is 1.

=item *

size - the number of words to return.  The default is 1.  If you supply a value for 'size', then 'min' and 'max' aren't paid attention to.

=item *

shuffle - whether or not the words should be randomly shuffled.  Set this to 0 if you don't want the words shuffled.  The default is 1.  Random::Data::WordList returns words in the order that they're viewed in the word list file, so shuffling will make sure that the results are a little more random.

=back 4


=head2 rand_chars()

This returns a list of random characters given a set of characters.  See below for possible parameters.

=over 4

=item *

set - the set of characters to be used.  This value can be either a reference to an array of strings, or one of the following:

    alpha        - alphabetic characters: a-z, A-Z
    upperalpha   - upper case alphabetic characters: A-Z
    loweralpha   - lower case alphabetic characters: a-z
    numeric      - numeric characters: 0-9
    alphanumeric - alphanumeric characters: a-z, A-Z, 0-9
    char         - non-alphanumeric characters: # ~ ! @ $ % ^ & * ( ) _ + = - { } | : " < > ? / . ' ; ] [ \ `
    all          - all of the above
    
=item *
    
min - the minimum number of characters to return.  The default is 0.

=item *

max - the maximum number of characters to return.  The default is the size of the set.

=item *

size - the number of characters to return.  The default is 1.  If you supply a value for 'size', then 'min' and 'max' aren't paid attention to.

=item *

shuffle - whether or not the characters should be randomly shuffled.  Set this to 0 if you want the characters to stay in the order received.  The default is 1.

=back 4


=head2 rand_set()

This returns a random set of elements given an initial set.  See below for possible parameters.

=over 4

=item *

set - the set of strings to be used.  This should be a reference to an array of strings.

=item *

min - the minimum number of strings to return.  The default is 0.

=item *

max - the maximum number of strings to return.  The default is the size of the set.

=item *

size - the number of strings to return.  The default is 1.  If you supply a value for 'size', then 'min' and 'max' aren't paid attention to.

=item *

shuffle - whether or not the strings should be randomly shuffled.  Set this to 0 if you want the strings to stay in the order received.  The default is 1.

=back 4


=head2 rand_enum()

This returns a random element given an initial set.  See below for possible parameters.

=over 4

=item *

set - the set of strings to be used.  This should be a reference to an array of strings.

=back 4


=head2 rand_date()

This returns a random date in the form "YYYY-MM-DD".  2-digit years are not currently supported.  Efforts are made to make sure you're returned a truly valid date--ie, you'll never be returned the date February 31st.  See the options below to find out how to control the date range.  Here are a few examples:

    # returns a date somewhere in between the current date, and one year from the current date
    $date = rand_date();    
    
    # returns a date somewhere in between September 21, 1978 and September 21, 1979
    $date = rand_date( min => '1978-9-21' );
    
    # returns a date somewhere in between September 21, 1978 and the current date
    $date = rand_date( min => '1978-9-21', max => 'now' );
    
    # returns a date somewhere in between the current date and September 21, 2008
    $date = rand_date( min => 'now', max => '2008-9-21' );
    
See below for possible parameters.

=over 4

=item *

min - the minimum date to be returned. It should be in the form "YYYY-MM-DD" or you can alternatively use the string "now" to represent the current date.  The default is the current date;

=item *

max - the maximum date to be returned. It should be in the form "YYYY-MM-DD" or you can alternatively use the string "now" to represent the current date.  The default is one year from the minimum date;

=back 4


=head2 rand_time()

This returns a random time in the form "HH:MM:SS".  24 hour times are supported.  See the options below to find out how to control the time range.  Here are a few examples:

    # returns a random 24-hr time (between 00:00:00 and 23:59:59)
    $time = rand_time();    
    
    # returns a time somewhere in between 04:00:00 and the end of the day
    $time = rand_time( min => '4:0:0' );
    
    # returns a time somewhere in between 8:00:00 and the current time (if it's after 8:00)
    $time = rand_time( min => '12:00:00', max => 'now' );
    
    # returns a date somewhere in between the current time and the end of the day
    $time = rand_time( min => 'now' );
    
See below for possible parameters.    

=over 4

=item *

min - the minimum time to be returned. It should be in the form "HH:MM:SS" or you can alternatively use the string "now" to represent the current time.  The default is 00:00:00;

=item *

max - the maximum time to be returned. It should be in the form "HH:MM:SS" or you can alternatively use the string "now" to represent the current time.  The default is 23:59:59;

=back 4


=head2 rand_datetime()

This returns a random date and time in the form "YYYY-MM-DD HH:MM:SS".  See the options below to find out how to control the date/time range.  Here are a few examples:

    # returns a date somewhere in between the current date/time, and one year from the current date/time
    $datetime = rand_datetime();
    
    # returns a date somewhere in between 4:00 September 21, 1978 and 4:00 September 21, 1979
    $datetime = rand_datetime( min => '1978-9-21 4:0:0' );
    
    # returns a date somewhere in between 4:00 September 21, 1978 and the current date
    $datetime = rand_datetime( min => '1978-9-21 4:0:0', max => 'now' );
    
    # returns a date somewhere in between the current date/time and the end of the day September 21, 2008
    $datetime = rand_datetime( min => 'now', max => '2008-9-21 23:59:59' );
    
See below for possible parameters.

=over 4

=item *

min - the minimum date/time to be returned. It should be in the form "YYYY-MM-DD HH:MM:SS" or you can alternatively use the string "now" to represent the current date/time.  The default is the current date/time;

=item *

max - the maximum date/time to be returned. It should be in the form "YYYY-MM-DD HH:MM:SS" or you can alternatively use the string "now" to represent the current date/time.  The default is one year from the minimum date/time;

=back 4


=head1 VERSION

0.01

=head1 AUTHOR

Adekunle Olonoh, ade@bottledsoftware.com

=head1 COPYRIGHT

Copyright (c) 2000 Adekunle Olonoh. All rights reserved. This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=head1 SEE ALSO

Data::Random::WordList

=cut
