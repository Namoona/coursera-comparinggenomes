#!/usr/bin/env perl

# PODNAME: number-of-breaks.pl
# ABSTRACT: Number of Breakpoints

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-09

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'number-of-breaks-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($permutation) = path($input_file)->lines( { chomp => 1 } );
$permutation =~ s/[^\d\s-]+//xmsg;
my @permutation = split /\s+/xms, $permutation;

printf "%d\n", number_of_breaks(@permutation);

sub number_of_breaks {
    my (@perm) = @_;

    my $breakpoints = 0;

    if ( $perm[0] != 1 ) {
        $breakpoints++;
    }
    if ( $perm[-1] != scalar @perm ) {
        $breakpoints++;
    }

    foreach my $i ( 0 .. scalar @perm - 2 ) {
        if ( $perm[ $i + 1 ] - $perm[$i] != 1 ) {
            $breakpoints++;
        }
    }

    return $breakpoints;
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

number-of-breaks.pl

Number of Breakpoints

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Number of Breakpoints Problem.

Input: A permutation.

Output: The number of breakpoints in this permutation.

=head1 EXAMPLES

    perl number-of-breaks.pl

    perl number-of-breaks.pl --input_file number-of-breaks-extra-input.txt

    diff <(perl number-of-breaks.pl) number-of-breaks-sample-output.txt

    diff \
        <(perl number-of-breaks.pl \
            --input_file number-of-breaks-extra-input.txt) \
        number-of-breaks-extra-output.txt

    perl number-of-breaks.pl --input_file dataset_287_5.txt \
        > dataset_287_5_output.txt

=head1 USAGE

    number-of-breaks.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A permutation".

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
