#!/usr/bin/env perl

# PODNAME: affine-gap.pl
# ABSTRACT: Alignment with Affine Gap Penalties

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-28

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
Readonly our $INFINITY     => 10**100;    # Substitute for infinity
Readonly our $DOWN         => 1;
Readonly our $RIGHT        => 2;
Readonly our $DOWNRIGHT    => 4;
Readonly our $LOWER2MIDDLE => 8;
Readonly our $MIDDLE2LOWER => 16;
Readonly our $UPPER2MIDDLE => 32;
Readonly our $MIDDLE2UPPER => 64;
Readonly our $SIGMA        => 11;
Readonly our $EPSILON      => 1;
Readonly our $LOWER        => 1;
Readonly our $MIDDLE       => 2;
Readonly our $UPPER        => 4;

# Default options
my $input_file  = 'affine-gap-sample-input.txt';
my $matrix_file = 'BLOSUM62.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $s, $t ) = path($input_file)->lines( { chomp => 1 } );

my $score = get_matrix($matrix_file);

my ( $max_score, $max_level, $backtrack ) = affine_gap( $s, $t, $score );

printf "%d\n%s\n%s\n", $max_score,
  output_alignment( $max_level, $backtrack, $s, $t );

sub affine_gap {
    my ( $v, $w, $score ) = @_;    ## no critic (ProhibitReusedNames)

    my @s;
    my @backtrack;
    $s[$MIDDLE][0][0] = 0;
    $s[$LOWER][0][0]  = -$INFINITY;
    $s[$UPPER][0][0]  = -$INFINITY;
    foreach my $i ( 1 .. length $v ) {
        $s[$MIDDLE][$i][0] = -( $SIGMA + $EPSILON * ( $i - 1 ) );
        $s[$LOWER][$i][0]  = -( $SIGMA + $EPSILON * ( $i - 1 ) );
        $s[$UPPER][$i][0]  = -$INFINITY;
    }
    foreach my $j ( 1 .. length $w ) {
        $s[$MIDDLE][0][$j] = -( $SIGMA + $EPSILON * ( $j - 1 ) );
        $s[$LOWER][0][$j]  = -$INFINITY;
        $s[$UPPER][0][$j]  = -( $SIGMA + $EPSILON * ( $j - 1 ) );
    }
    foreach my $i ( 1 .. length $v ) {
        foreach my $j ( 1 .. length $w ) {
            my $match =
              $score->{ substr $v, $i - 1, 1 }{ substr $w, $j - 1, 1 };
            $s[$LOWER][$i][$j] = max(
                $s[$LOWER][ $i - 1 ][$j] - $EPSILON,
                $s[$MIDDLE][ $i - 1 ][$j] - $SIGMA,
            );
            $s[$UPPER][$i][$j] = max(
                $s[$UPPER][$i][ $j - 1 ] - $EPSILON,
                $s[$MIDDLE][$i][ $j - 1 ] - $SIGMA,
            );
            $s[$MIDDLE][$i][$j] = max(
                $s[$MIDDLE][ $i - 1 ][ $j - 1 ] + $match,
                $s[$LOWER][$i][$j],
                $s[$UPPER][$i][$j],
            );
            if ( $s[$MIDDLE][$i][$j] ==
                $s[$MIDDLE][ $i - 1 ][ $j - 1 ] + $match )
            {
                $backtrack[$MIDDLE][$i][$j] = $DOWNRIGHT;
            }
            elsif ( $s[$MIDDLE][$i][$j] == $s[$LOWER][$i][$j] ) {
                $backtrack[$MIDDLE][$i][$j] = $MIDDLE2LOWER;
            }
            elsif ( $s[$MIDDLE][$i][$j] == $s[$UPPER][$i][$j] ) {
                $backtrack[$MIDDLE][$i][$j] = $MIDDLE2UPPER;
            }
            if ( $s[$LOWER][$i][$j] == $s[$LOWER][ $i - 1 ][$j] - $EPSILON ) {
                $backtrack[$LOWER][$i][$j] = $DOWN;
            }
            elsif ( $s[$LOWER][$i][$j] == $s[$MIDDLE][ $i - 1 ][$j] - $SIGMA ) {
                $backtrack[$LOWER][$i][$j] = $LOWER2MIDDLE;
            }
            if ( $s[$UPPER][$i][$j] == $s[$UPPER][$i][ $j - 1 ] - $EPSILON ) {
                $backtrack[$UPPER][$i][$j] = $RIGHT;
            }
            elsif ( $s[$UPPER][$i][$j] == $s[$MIDDLE][$i][ $j - 1 ] - $SIGMA ) {
                $backtrack[$UPPER][$i][$j] = $UPPER2MIDDLE;
            }
        }
    }

    ## no critic (ProhibitReusedNames)
    my $max_score =
      max( $s[$MIDDLE][-1][-1], $s[$LOWER][-1][-1], $s[$UPPER][-1][-1], );
    my $max_level =
        $s[$MIDDLE][-1][-1] == $max_score ? $MIDDLE
      : $s[$LOWER][-1][-1] == $max_score  ? $LOWER
      : $s[$UPPER][-1][-1] == $max_score  ? $UPPER
      :                                     undef;
    ## use critic

    return $max_score, $max_level, \@backtrack;
}

sub output_alignment {
    my ( $level, $backtrack, $v, $w ) = @_;   ## no critic (ProhibitReusedNames)

    my $i = length $v;
    my $j = length $w;

    my @v_aln;
    my @w_aln;

    while (1) {
        last if $i == 0 && $j == 0;
        ## no critic (ProhibitCascadingIfElse)
        if ( $level == $LOWER
            && ( $j == 0 || $backtrack->[$LOWER][$i][$j] == $DOWN ) )
        {
            push @v_aln, substr $v, --$i, 1;
            push @w_aln, q{-};
        }
        elsif ($level == $LOWER
            && $backtrack->[$LOWER][$i][$j] == $LOWER2MIDDLE )
        {
            $level = $MIDDLE;
            push @v_aln, substr $v, --$i, 1;
            push @w_aln, q{-};
        }
        elsif ( $level == $UPPER
            && ( $i == 0 || $backtrack->[$UPPER][$i][$j] == $RIGHT ) )
        {
            push @w_aln, substr $w, --$j, 1;
            push @v_aln, q{-};
        }
        elsif ($level == $UPPER
            && $backtrack->[$UPPER][$i][$j] == $UPPER2MIDDLE )
        {
            $level = $MIDDLE;
            push @w_aln, substr $w, --$j, 1;
            push @v_aln, q{-};
        }
        elsif ($level == $MIDDLE
            && $backtrack->[$MIDDLE][$i][$j] == $DOWNRIGHT )
        {
            push @v_aln, substr $v, --$i, 1;
            push @w_aln, substr $w, --$j, 1;
        }
        elsif ($level == $MIDDLE
            && $backtrack->[$MIDDLE][$i][$j] == $MIDDLE2LOWER )
        {
            $level = $LOWER;
        }
        elsif ($level == $MIDDLE
            && $backtrack->[$MIDDLE][$i][$j] == $MIDDLE2UPPER )
        {
            $level = $UPPER;
        }
        ## use critic
    }

    my $v_aln = join q{}, reverse @v_aln;
    my $w_aln = join q{}, reverse @w_aln;

    return $v_aln, $w_aln;
}

sub get_matrix {
    my ($file) = @_;

    my (@matrix) = path($file)->lines( { chomp => 1 } );
    my (@amino_acids) = split /\s+/xms, shift @matrix;
    shift @amino_acids;
    my $score = {};    ## no critic (ProhibitReusedNames)
    while (@matrix) {
        my @scores = split /\s+/xms, shift @matrix;
        my $amino_acid2 = shift @scores;
        foreach my $amino_acid1 (@amino_acids) {
            $score->{$amino_acid1}{$amino_acid2} = shift @scores;
        }
    }

    return $score;
}

# Get and check command line options
sub get_and_check_options {

    # Get options
    GetOptions(
        'input_file=s'  => \$input_file,
        'matrix_file=s' => \$matrix_file,
        'debug'         => \$debug,
        'help'          => \$help,
        'man'           => \$man,
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

affine-gap.pl

Alignment with Affine Gap Penalties

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Alignment with Affine Gap Penalties Problem.

Input: Two amino acid strings I<v> and I<w> (each of length at most 100).

Output: The maximum alignment score between v and w, followed by an alignment of
I<v> and I<w> achieving this maximum score. Use the BLOSUM62 scoring matrix, a
gap opening penalty of 11, and a gap extension penalty of 1.

=head1 EXAMPLES

    perl affine-gap.pl

    perl affine-gap.pl --input_file affine-gap-extra-input.txt

    diff <(perl affine-gap.pl) affine-gap-sample-output.txt

    diff \
        <(perl affine-gap.pl \
            --input_file affine-gap-extra-input.txt) \
        affine-gap-extra-output.txt

    perl affine-gap.pl --input_file dataset_249_8.txt \
        > dataset_249_8_output.txt

=head1 USAGE

    affine-gap.pl
        [--input_file FILE]
        [--matrix_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two amino acid strings I<v> and I<w> (each of length
at most 100)".

=item B<--matrix_file FILE>

The scoring matrix file.

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
