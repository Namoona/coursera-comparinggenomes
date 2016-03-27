#!/usr/bin/env perl

# PODNAME: edit-distance.pl
# ABSTRACT: Edit Distance

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
use List::Util qw(min);

# Constants
Readonly our $DOWN      => 1;
Readonly our $RIGHT     => 2;
Readonly our $DOWNRIGHT => 4;

# Default options
my $input_file = 'edit-distance-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $s, $t ) = path($input_file)->lines( { chomp => 1 } );

printf "%d\n", edit_distance( $s, $t );

sub edit_distance {
    my ( $v, $w ) = @_;

    my @s;
    $s[0][0] = 0;
    foreach my $i ( 1 .. length $v ) {
        $s[$i][0] = $s[ $i - 1 ][0] + 1;
    }
    foreach my $j ( 1 .. length $w ) {
        $s[0][$j] = $s[0][ $j - 1 ] + 1;
    }
    foreach my $i ( 1 .. length $v ) {
        foreach my $j ( 1 .. length $w ) {
            my $match =
              ( substr $v, $i - 1, 1 ) eq ( substr $w, $j - 1, 1 ) ? 0 : 1;
            $s[$i][$j] = min(
                $s[ $i - 1 ][$j] + 1,
                $s[$i][ $j - 1 ] + 1,
                $s[ $i - 1 ][ $j - 1 ] + $match,
            );
        }
    }

    return $s[-1][-1];
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

edit-distance.pl

Edit Distance

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Edit Distance Problem.

Input: Two strings.

Output: The edit distance between these strings.

=head1 EXAMPLES

    perl edit-distance.pl

    perl edit-distance.pl --input_file edit-distance-extra-input.txt

    diff <(perl edit-distance.pl) edit-distance-sample-output.txt

    diff \
        <(perl edit-distance.pl --input_file edit-distance-extra-input.txt) \
        edit-distance-extra-output.txt

    perl edit-distance.pl --input_file dataset_248_3.txt \
        > dataset_248_3_output.txt

=head1 USAGE

    edit-distance.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Two strings".

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
