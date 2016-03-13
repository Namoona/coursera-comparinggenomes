#!/usr/bin/env perl

# PODNAME: change.pl
# ABSTRACT: Change

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-13

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'change-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $money, $coins ) = path($input_file)->lines( { chomp => 1 } );
my @coins = split /,/xms, $coins;

printf "%s\n", join "\n", change( $money, @coins );

sub change {
    my ( $money, @coins ) = @_;    ## no critic (ProhibitReusedNames)

    my @min_num_coins = (0);
    foreach my $m ( 1 .. $money ) {
        foreach my $i ( 0 .. ( scalar @coins ) - 1 ) {
            if ( $m >= $coins[$i] ) {
                if (  !$min_num_coins[$m]
                    || $min_num_coins[ $m - $coins[$i] ] + 1 <
                    $min_num_coins[$m] )
                {
                    $min_num_coins[$m] = $min_num_coins[ $m - $coins[$i] ] + 1;
                }
            }
        }
    }

    return $min_num_coins[$money];
}

# Get and check command line options
sub get_and_check_options {

    # Get options
    GetOptions(
        'input_file=s' => \$input_file,
        'debug'        => \$debug,
        'help'         => \$help,
        'man'          => \$man,
    ) or pod2usage(2);

    # Documentation
    if ($help) {
        pod2usage(1);
    }
    elsif ($man) {
        pod2usage( -verbose => 2 );
    }

    return;
}

__END__
=pod

=encoding UTF-8

=head1 NAME

change.pl

Change

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Change Problem.

Input: An integer I<money> and an array I<Coins> = (I<coin1>, ..., I<coind>).

Output: The minimum number of coins with denominations I<Coins> that changes
I<money>.

=head1 EXAMPLES

    perl change.pl

    perl change.pl --input_file change-extra-input.txt

    diff <(perl change.pl) change-sample-output.txt

    diff \
        <(perl change.pl --input_file change-extra-input.txt) \
        change-extra-output.txt

    perl change.pl --input_file dataset_243_9.txt > dataset_243_9_output.txt

=head1 USAGE

    change.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer I<money> and an array I<Coins> =
(I<coin1>, ..., I<coind>)".

=item B<--debug>

Print debugging information.

=item B<--help>

Print a brief help message and exit.

=item B<--man>

Print this script's manual page and exit.

=back

=head1 DEPENDENCIES

None

=head1 AUTHOR

=over 4

=item *

Ian Sealy

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2016 by Ian Sealy.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut
