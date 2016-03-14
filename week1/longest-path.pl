#!/usr/bin/env perl

# PODNAME: longest-path.pl
# ABSTRACT: Longest Path

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-14

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

use List::Util qw(max);

# Default options
my $input_file = 'longest-path-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $integers, @matrices ) = path($input_file)->lines( { chomp => 1 } );
my ( $n, $m ) = split /\s+/xms, $integers;
my @down;
foreach my $i ( 1 .. $n ) {
    my @weights = split /\s+/xms, shift @matrices;
    foreach my $j ( 0 .. $m ) {
        $down[$i][$j] = shift @weights;
    }
}
shift @matrices;
my @right;    ## no critic (ProhibitAmbiguousNames)
foreach my $i ( 0 .. $n ) {
    my @weights = split /\s+/xms, shift @matrices;
    foreach my $j ( 1 .. $m ) {
        $right[$i][$j] = shift @weights;
    }
}

printf "%s\n", join "\n", longest_path( $n, $m, \@down, \@right );

sub longest_path {
    ## no critic (ProhibitReusedNames, ProhibitAmbiguousNames)
    my ( $n, $m, $down, $right ) = @_;
    ## use critic

    my @s;
    $s[0][0] = 0;
    foreach my $i ( 1 .. $n ) {
        $s[$i][0] = $s[ $i - 1 ][0] + $down->[$i][0];
    }
    foreach my $j ( 1 .. $m ) {
        $s[0][$j] = $s[0][ $j - 1 ] + $right->[0][$j];
    }
    foreach my $i ( 1 .. $n ) {
        foreach my $j ( 1 .. $m ) {
            $s[$i][$j] = max(
                $s[ $i - 1 ][$j] + $down->[$i][$j],
                $s[$i][ $j - 1 ] + $right->[$i][$j]
            );
        }
    }

    return $s[$n][$m];
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

longest-path.pl

Longest Path

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script finds the length of a longest path in the Manhattan Tourist Problem.

Input: Integers I<n> and I<m>, followed by an I<n> × (I<m> + 1) matrix I<Down>
and an (I<n> + 1) × I<m> matrix I<Right>. The two matrices are separated by the
- symbol.

Output: The length of a longest path from source (0, 0) to sink (I<n>, I<m>) in
the I<n> × I<m> rectangular grid whose edges are defined by the matrices I<Down>
and I<Right>.

=head1 EXAMPLES

    perl longest-path.pl

    perl longest-path.pl --input_file longest-path-extra-input.txt

    diff <(perl longest-path.pl) longest-path-sample-output.txt

    diff \
        <(perl longest-path.pl --input_file longest-path-extra-input.txt) \
        longest-path-extra-output.txt

    perl longest-path.pl --input_file dataset_261_9.txt \
        > dataset_261_9_output.txt

=head1 USAGE

    longest-path.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Integers I<n> and I<m>, followed by an
I<n> × (I<m> + 1) matrix I<Down> and an (I<n> + 1) × I<m> matrix I<Right>".

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
