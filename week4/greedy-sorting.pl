#!/usr/bin/env perl

# PODNAME: greedy-sorting.pl
# ABSTRACT: Greedy Sorting

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-07

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'greedy-sorting-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($permutation) = path($input_file)->lines( { chomp => 1 } );
$permutation =~ s/[^\d\s-]+//xmsg;
my @permutation = split /\s+/xms, $permutation;

my @permutations = greedy_sorting(@permutation);

foreach my $permutation (@permutations) {
    @{$permutation} = map { $_ > 0 ? q{+} . $_ : $_ } @{$permutation};
    printf "(%s)\n", join q{ }, @{$permutation};
}

sub greedy_sorting {
    my (@perm) = @_;

    my @perms;

    foreach my $k ( 1 .. scalar @perm ) {
        if ( abs $perm[ $k - 1 ] != $k ) {
            my $i = $k;
            while ( abs $perm[$i] != $k ) {
                $i++;
            }
            my @reversal = splice @perm, $k - 1, $i - $k + 2;
            ## no critic (ProhibitMagicNumbers)
            splice @perm, $k - 1, 0, ( map { $_ * -1 } reverse @reversal );
            ## use critic
            push @perms, [@perm];
        }
        if ( $perm[ $k - 1 ] == -$k ) {
            $perm[ $k - 1 ] *= -1;    ## no critic (ProhibitMagicNumbers)
            push @perms, [@perm];
        }
    }

    return @perms;
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

greedy-sorting.pl

Greedy Sorting

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Greedy Sorting.

Input: A permutation I<P>.

Output: The sequence of permutations corresponding to applying GREEDYSORTING to
I<P>, ending with the identity permutation.

=head1 EXAMPLES

    perl greedy-sorting.pl

    perl greedy-sorting.pl --input_file greedy-sorting-extra-input.txt

    diff <(perl greedy-sorting.pl) greedy-sorting-sample-output.txt

    diff \
        <(perl greedy-sorting.pl --input_file greedy-sorting-extra-input.txt) \
        greedy-sorting-extra-output.txt

    perl greedy-sorting.pl --input_file dataset_286_3.txt \
        > dataset_286_3_output.txt

=head1 USAGE

    greedy-sorting.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A permutation I<P>".

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
