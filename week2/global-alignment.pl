#!/usr/bin/env perl

# PODNAME: global-alignment.pl
# ABSTRACT: Global Alignment

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-25

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
Readonly our $DOWN      => 1;
Readonly our $RIGHT     => 2;
Readonly our $DOWNRIGHT => 4;
Readonly our $SIGMA     => 5;

# Default options
my $input_file  = 'global-alignment-sample-input.txt';
my $matrix_file = 'BLOSUM62.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $s, $t ) = path($input_file)->lines( { chomp => 1 } );

my $score = get_matrix($matrix_file);

my ( $max_score, $backtrack ) = global_alignment( $s, $t, $score );

printf "%d\n%s\n%s\n", $max_score, output_alignment( $backtrack, $s, $t );

sub global_alignment {
    my ( $v, $w, $score ) = @_;    ## no critic (ProhibitReusedNames)

    my @s;
    my @backtrack;
    $s[0][0] = 0;
    foreach my $i ( 1 .. length $v ) {
        $s[$i][0] = $s[ $i - 1 ][0] - $SIGMA;
    }
    foreach my $j ( 1 .. length $w ) {
        $s[0][$j] = $s[0][ $j - 1 ] - $SIGMA;
    }
    foreach my $i ( 1 .. length $v ) {
        foreach my $j ( 1 .. length $w ) {
            my $match =
              $score->{ substr $v, $i - 1, 1 }{ substr $w, $j - 1, 1 };
            $s[$i][$j] = max(
                $s[ $i - 1 ][$j] - $SIGMA,
                $s[$i][ $j - 1 ] - $SIGMA,
                $s[ $i - 1 ][ $j - 1 ] + $match,
            );
            if ( $s[$i][$j] == $s[ $i - 1 ][$j] - $SIGMA ) {
                $backtrack[$i][$j] = $DOWN;
            }
            elsif ( $s[$i][$j] == $s[$i][ $j - 1 ] - $SIGMA ) {
                $backtrack[$i][$j] = $RIGHT;
            }
            elsif ( $s[$i][$j] == $s[ $i - 1 ][ $j - 1 ] + $match ) {
                $backtrack[$i][$j] = $DOWNRIGHT;
            }
        }
    }

    return $s[-1][-1], \@backtrack;
}

sub output_alignment {
    my ( $backtrack, $v, $w ) = @_;    ## no critic (ProhibitReusedNames)

    my $i = length $v;
    my $j = length $w;

    my @v_aln;
    my @w_aln;

    while (1) {
        last if $i == 0 && $j == 0;
        if ( $j == 0 || $backtrack->[$i][$j] == $DOWN ) {
            push @v_aln, substr $v, --$i, 1;
            push @w_aln, q{-};
        }
        elsif ( $i == 0 || $backtrack->[$i][$j] == $RIGHT ) {
            push @w_aln, substr $w, --$j, 1;
            push @v_aln, q{-};
        }
        else {
            push @v_aln, substr $v, --$i, 1;
            push @w_aln, substr $w, --$j, 1;
        }
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

global-alignment.pl

Global Alignment

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Global Alignment Problem.

Input: Two protein strings written in the single-letter amino acid alphabet.

Output: The maximum alignment score of these strings followed by an alignment
achieving this maximum score. Use the BLOSUM62 scoring matrix and indel penalty
σ = 5.

=head1 EXAMPLES

    perl global-alignment.pl

    perl global-alignment.pl --input_file global-alignment-extra-input.txt

    diff <(perl global-alignment.pl) global-alignment-sample-output.txt

    diff \
        <(perl global-alignment.pl \
            --input_file global-alignment-extra-input.txt) \
        global-alignment-extra-output.txt

    perl global-alignment.pl --input_file dataset_247_3.txt \
        > dataset_247_3_output.txt

=head1 USAGE

    global-alignment.pl
        [--input_file FILE]
        [--matrix_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two protein strings written in the single-letter
amino acid alphabet".

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
