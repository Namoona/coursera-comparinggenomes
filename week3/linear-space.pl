#!/usr/bin/env perl

# PODNAME: linear-space.pl
# ABSTRACT: Middle Edge in Linear Space

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-03

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
my $input_file  = 'linear-space-sample-input.txt';
my $matrix_file = 'BLOSUM62.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $s, $t ) = path($input_file)->lines( { chomp => 1 } );

my $score = get_matrix($matrix_file);

my ( $mid_node, $mid_edge ) =
  middle_edge( 0, length $s, 0, length $t, $s, $t, $score );

my $middle = int( ( length $t ) / 2 );
my ( $row, $col ) = ( $mid_node, $middle );
if ( $mid_edge == $DOWN ) {
    $row++;
}
elsif ( $mid_edge == $RIGHT ) {
    $col++;
}
else {
    $row++;
    $col++;
}

printf "(%d, %d) (%d, %d)\n", $mid_node, $middle, $row, $col;

sub middle_edge {    ## no critic (ProhibitManyArgs)
    ## no critic (ProhibitAmbiguousNames, ProhibitReusedNames)
    my ( $top, $bottom, $left, $right, $v, $w, $score ) = @_;
    ## use critic

    $v = substr $v, $top,  $bottom - $top;
    $w = substr $w, $left, $right - $left;

    my $middle = int( ( length $w ) / 2 );    ## no critic (ProhibitReusedNames)

    my $w1 = substr $w, 0, $middle;
    my ( $from_source, undef ) = alignment( $v, $w1, $score );

    my $w2 = reverse substr $w, $middle;
    my ( $to_sink, $backtrack ) =
      alignment( ( scalar reverse $v ), $w2, $score );
    @{$to_sink}   = reverse @{$to_sink};
    @{$backtrack} = reverse @{$backtrack};

    my ( $max_length, $mid_node, $mid_edge ); ## no critic (ProhibitReusedNames)
    foreach my $i ( 0 .. scalar @{$from_source} - 1 ) {
        if ( !defined $max_length
            || $max_length < $from_source->[$i] + $to_sink->[$i] )
        {
            $max_length = $from_source->[$i] + $to_sink->[$i];
            $mid_node   = $i + $top;
            $mid_edge   = $backtrack->[$i];
        }
    }

    return $mid_node, $mid_edge;
}

sub alignment {
    my ( $v, $w, $score ) = @_;    ## no critic (ProhibitReusedNames)

    my @s;
    my @backtrack = ($RIGHT);
    $s[0][0] = 0;
    foreach my $i ( 1 .. length $v ) {
        $s[0][$i] = $s[0][ $i - 1 ] - $SIGMA;
    }
    foreach my $j ( 1 .. length $w ) {
        $s[$j][0] = $s[ $j - 1 ][0] - $SIGMA;
        foreach my $i ( 1 .. length $v ) {
            my $match =
              $score->{ substr $v, $i - 1, 1 }{ substr $w, $j - 1, 1 };
            $s[$j][$i] = max(
                $s[$j][ $i - 1 ] - $SIGMA,
                $s[ $j - 1 ][$i] - $SIGMA,
                $s[ $j - 1 ][ $i - 1 ] + $match,
            );
            if ( $j == length $w ) {    # Last column
                if ( $s[$j][$i] == $s[$j][ $i - 1 ] - $SIGMA ) {
                    $backtrack[$i] = $DOWN;
                }
                elsif ( $s[$j][$i] == $s[ $j - 1 ][$i] - $SIGMA ) {
                    $backtrack[$i] = $RIGHT;
                }
                elsif ( $s[$j][$i] == $s[ $j - 1 ][ $i - 1 ] + $match ) {
                    $backtrack[$i] = $DOWNRIGHT;
                }
            }
        }
        delete $s[ $j - 1 ];
    }

    return $s[-1], \@backtrack;
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

linear-space.pl

Middle Edge in Linear Space

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Middle Edge in Linear Space Problem.

Input: Two amino acid strings.

Output: A middle edge in the alignment graph in the form
"(I<i>, I<j>) (I<k>, I<l>)", where (I<i>, I<j>) connects to (I<k>, I<l>). To
compute scores, use the BLOSUM62 scoring matrix and a (linear) indel penalty
equal to 5.

=head1 EXAMPLES

    perl linear-space.pl

    perl linear-space.pl --input_file linear-space-extra-input.txt

    diff <(perl linear-space.pl) linear-space-sample-output.txt

    diff \
        <(perl linear-space.pl --input_file linear-space-extra-input.txt) \
        linear-space-extra-output.txt

    perl linear-space.pl --input_file dataset_250_12.txt \
        > dataset_250_12_output.txt

=head1 USAGE

    linear-space.pl
        [--input_file FILE]
        [--matrix_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two amino acid strings".

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
