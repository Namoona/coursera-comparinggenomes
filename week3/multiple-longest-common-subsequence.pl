#!/usr/bin/env perl

# PODNAME: multiple-longest-common-subsequence.pl
# ABSTRACT: Multiple Longest Common Subsequence

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-04

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

use Readonly;
use List::Util qw(max);

# Constants
Readonly our $NOGAP => 1;
Readonly our $GAPV  => 2;
Readonly our $GAPW  => 4;
Readonly our $GAPU  => 8;

# Default options
my $input_file = 'multiple-longest-common-subsequence-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $v, $w, $u ) = path($input_file)->lines( { chomp => 1 } );

my ( $max_score, $backtrack ) =
  multiple_longest_common_subsequence( $v, $w, $u );

printf "%d\n%s\n%s\n%s\n", $max_score,
  output_alignment( $backtrack, $v, $w, $u );

sub multiple_longest_common_subsequence {
    my ( $v, $w, $u ) = @_;    ## no critic (ProhibitReusedNames)

    my @s;
    my @backtrack;
    foreach my $i ( 0 .. length $v ) {
        foreach my $j ( 0 .. length $w ) {
            $s[$i][$j][0]         = 0;
            $backtrack[$i][$j][0] = $GAPU;
        }
    }
    foreach my $i ( 0 .. length $v ) {
        foreach my $k ( 0 .. length $u ) {
            $s[$i][0][$k]         = 0;
            $backtrack[$i][0][$k] = $GAPW;
        }
    }
    foreach my $j ( 0 .. length $w ) {
        foreach my $k ( 0 .. length $u ) {
            $s[0][$j][$k]         = 0;
            $backtrack[0][$j][$k] = $GAPV;
        }
    }
    my $max_score = 0;    ## no critic (ProhibitReusedNames)
    foreach my $i ( 1 .. length $v ) {
        foreach my $j ( 1 .. length $w ) {
            foreach my $k ( 1 .. length $u ) {
                my $match =
                     ( substr $v, $i - 1, 1 ) eq ( substr $w, $j - 1, 1 )
                  && ( substr $w, $j - 1, 1 ) eq ( substr $u, $k - 1, 1 )
                  ? 1
                  : 0;
                $s[$i][$j][$k] = max(
                    $s[ $i - 1 ][$j][$k],
                    $s[$i][ $j - 1 ][$k],
                    $s[$i][$j][ $k - 1 ],
                    $s[ $i - 1 ][ $j - 1 ][$k],
                    $s[ $i - 1 ][$j][ $k - 1 ],
                    $s[$i][ $j - 1 ][ $k - 1 ],
                    $s[ $i - 1 ][ $j - 1 ][ $k - 1 ] + $match,
                );
                $backtrack[$i][$j][$k] =
                    $s[$i][$j][$k] == $s[ $i - 1 ][$j][$k]       ? $GAPW + $GAPU
                  : $s[$i][$j][$k] == $s[$i][ $j - 1 ][$k]       ? $GAPV + $GAPU
                  : $s[$i][$j][$k] == $s[$i][$j][ $k - 1 ]       ? $GAPV + $GAPW
                  : $s[$i][$j][$k] == $s[ $i - 1 ][ $j - 1 ][$k] ? $GAPU
                  : $s[$i][$j][$k] == $s[ $i - 1 ][$j][ $k - 1 ] ? $GAPW
                  : $s[$i][$j][$k] == $s[$i][ $j - 1 ][ $k - 1 ] ? $GAPV
                  : $s[$i][$j][$k] == $s[ $i - 1 ][ $j - 1 ][ $k - 1 ] + $match
                  ? $NOGAP
                  : undef;
            }
        }
    }

    return $s[-1][-1][-1], \@backtrack;
}

sub output_alignment {
    my ( $backtrack, $v, $w, $u ) = @_;    ## no critic (ProhibitReusedNames)

    my $i = length $v;
    my $j = length $w;
    my $k = length $u;

    my @v_aln;
    my @w_aln;
    my @u_aln;

    while (1) {
        last if $i == 0 && $j == 0 && $k == 0;
        my $step = $backtrack->[$i][$j][$k];
        if ( $i == 0 || $step & $GAPV ) {
            push @v_aln, q{-};
        }
        else {
            push @v_aln, substr $v, --$i, 1;
        }
        if ( $j == 0 || $step & $GAPW ) {
            push @w_aln, q{-};
        }
        else {
            push @w_aln, substr $w, --$j, 1;
        }
        if ( $k == 0 || $step & $GAPU ) {
            push @u_aln, q{-};
        }
        else {
            push @u_aln, substr $u, --$k, 1;
        }
    }

    my $v_aln = join q{}, reverse @v_aln;
    my $w_aln = join q{}, reverse @w_aln;
    my $u_aln = join q{}, reverse @u_aln;

    return $v_aln, $w_aln, $u_aln;
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

multiple-longest-common-subsequence.pl

Multiple Longest Common Subsequence

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Multiple Longest Common Subsequence Problem.

Input: Three DNA strings of length at most 10.

Output: The length of a longest common subsequence of these three strings,
followed by a multiple alignment of the three strings corresponding to such an
alignment.

=head1 EXAMPLES

    perl multiple-longest-common-subsequence.pl

    perl multiple-longest-common-subsequence.pl \
        --input_file multiple-longest-common-subsequence-extra-input.txt

    diff <(perl multiple-longest-common-subsequence.pl) \
        multiple-longest-common-subsequence-sample-output.txt

    diff \
        <(perl multiple-longest-common-subsequence.pl \
            --input_file multiple-longest-common-subsequence-extra-input.txt) \
        multiple-longest-common-subsequence-extra-output.txt

    perl multiple-longest-common-subsequence.pl --input_file dataset_251_5.txt \
        > dataset_251_5_output.txt

=head1 USAGE

    multiple-longest-common-subsequence.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Three DNA strings of length at most 10".

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
