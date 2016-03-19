#!/usr/bin/env perl

# PODNAME: longest-common-subsequence.pl
# ABSTRACT: Longest Common Subsequence

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-19

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
my $input_file = 'longest-common-subsequence-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $s, $t ) = path($input_file)->lines( { chomp => 1 } );

my $backtrack = lcs_backtrack( $s, $t );

printf "%s\n", output_lcs( q{}, $backtrack, $s, length $s, length $t );

sub lcs_backtrack {
    my ( $v, $w ) = @_;

    my @s;
    my @backtrack;
    foreach my $i ( 0 .. length $v ) {
        $s[$i][0] = 0;
    }
    foreach my $j ( 0 .. length $w ) {
        $s[0][$j] = 0;
    }
    foreach my $i ( 1 .. length $v ) {
        foreach my $j ( 1 .. length $w ) {
            my $match = ( substr $v, $i - 1, 1 ) eq ( substr $w, $j - 1, 1 );
            $s[$i][$j] = max(
                $s[ $i - 1 ][$j],
                $s[$i][ $j - 1 ],
                ( $s[ $i - 1 ][ $j - 1 ] + 1 ) * $match,
            );
            if ( $s[$i][$j] == $s[ $i - 1 ][$j] ) {
                $backtrack[$i][$j] = $DOWN;
            }
            elsif ( $s[$i][$j] == $s[$i][ $j - 1 ] ) {
                $backtrack[$i][$j] = $RIGHT;
            }
            elsif ( $s[$i][$j] == $s[ $i - 1 ][ $j - 1 ] + 1 && $match ) {
                $backtrack[$i][$j] = $DOWNRIGHT;
            }
        }
    }

    return \@backtrack;
}

sub output_lcs {
    my ( $lcs, $backtrack, $v, $i, $j ) = @_; ## no critic (ProhibitReusedNames)

    no warnings 'recursion';                  ## no critic (ProhibitNoWarnings)

    if ( $i == 0 || $j == 0 ) {
        return $lcs;
    }
    if ( $backtrack->[$i][$j] == $DOWN ) {
        $lcs .= output_lcs( $lcs, $backtrack, $v, $i - 1, $j );
    }
    elsif ( $backtrack->[$i][$j] == $RIGHT ) {
        $lcs .= output_lcs( $lcs, $backtrack, $v, $i, $j - 1 );
    }
    else {
        $lcs .= output_lcs( $lcs, $backtrack, $v, $i - 1, $j - 1 );
        $lcs .= substr $v, $i - 1, 1;
    }

    return $lcs;
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

longest-common-subsequence.pl

Longest Common Subsequence

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Longest Common Subsequence Problem.

Input: Two strings I<s> and I<t>.

Output: A longest common subsequence of I<s> and I<t>.

=head1 EXAMPLES

    perl longest-common-subsequence.pl

    perl longest-common-subsequence.pl \
        --input_file longest-common-subsequence-extra-input.txt

    diff <(perl longest-common-subsequence.pl) \
        longest-common-subsequence-sample-output.txt

    diff \
        <(perl longest-common-subsequence.pl \
            --input_file longest-common-subsequence-extra-input.txt) \
        longest-common-subsequence-extra-output.txt

    perl longest-common-subsequence.pl --input_file dataset_245_5.txt \
        > dataset_245_5_output.txt

=head1 USAGE

    longest-common-subsequence.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two strings I<s> and I<t>".

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
