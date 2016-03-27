#!/usr/bin/env perl

# PODNAME: fitting-alignment.pl
# ABSTRACT: Fitting Alignment

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-27

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

# Default options
my $input_file = 'fitting-alignment-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $s, $t ) = path($input_file)->lines( { chomp => 1 } );

my ( $max_score, $max_i, $backtrack ) = fitting_alignment( $s, $t );

printf "%d\n%s\n%s\n", $max_score,
  output_alignment( $backtrack, $s, $t, $max_i, length $t );

sub fitting_alignment {
    my ( $v, $w ) = @_;

    my @s;
    my @backtrack;
    foreach my $i ( 0 .. length $v ) {
        $s[$i][0] = 0;
    }
    foreach my $j ( 1 .. length $w ) {
        $s[0][$j] = $s[0][ $j - 1 ] - 1;
    }
    ## no critic (ProhibitReusedNames)
    my $max_score = 0;
    my $max_i     = 0;
    ## use critic
    foreach my $i ( 1 .. length $v ) {
        foreach my $j ( 1 .. length $w ) {
            ## no critic (ProhibitMagicNumbers)
            my $match =
              ( substr $v, $i - 1, 1 ) eq ( substr $w, $j - 1, 1 ) ? 1 : -1;
            ## use critic
            $s[$i][$j] = max(
                $s[ $i - 1 ][$j] - 1,
                $s[$i][ $j - 1 ] - 1,
                $s[ $i - 1 ][ $j - 1 ] + $match,
            );
            if ( $s[$i][$j] == $s[ $i - 1 ][$j] - 1 ) {
                $backtrack[$i][$j] = $DOWN;
            }
            elsif ( $s[$i][$j] == $s[$i][ $j - 1 ] - 1 ) {
                $backtrack[$i][$j] = $RIGHT;
            }
            elsif ( $s[$i][$j] == $s[ $i - 1 ][ $j - 1 ] + $match ) {
                $backtrack[$i][$j] = $DOWNRIGHT;
            }
        }
        if ( $s[$i][-1] > $max_score ) {
            $max_score = $s[$i][-1];
            $max_i     = $i;
        }
    }

    return $max_score, $max_i, \@backtrack;
}

sub output_alignment {
    my ( $backtrack, $v, $w, $i, $j ) = @_;   ## no critic (ProhibitReusedNames)

    my @v_aln;
    my @w_aln;

    while (1) {
        last if $j == 0;
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

fitting-alignment.pl

Fitting Alignment

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Fitting Alignment Problem.

Input: Two nucleotide strings I<v> and I<w>, where I<v> has length at most 1000
and I<w> has length at most 100.

Output: A highest-scoring fitting alignment between I<v> and I<w>. Use the
simple scoring method in which matches count +1 and both the mismatch and indel
penalties are 1.

=head1 EXAMPLES

    perl fitting-alignment.pl

    perl fitting-alignment.pl --input_file fitting-alignment-extra-input.txt

    diff <(perl fitting-alignment.pl) fitting-alignment-sample-output.txt

    diff \
        <(perl fitting-alignment.pl \
            --input_file fitting-alignment-extra-input.txt) \
        fitting-alignment-extra-output.txt

    perl fitting-alignment.pl --input_file dataset_248_5.txt \
        > dataset_248_5_output.txt

=head1 USAGE

    fitting-alignment.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two nucleotide strings I<v> and I<w>, where I<v> has
length at most 1000 and I<w> has length at most 100".

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
