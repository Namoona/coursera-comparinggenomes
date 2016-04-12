#!/usr/bin/env perl

# PODNAME: cycle-to-chromosome.pl
# ABSTRACT: Cycle To Chromosome

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-12

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'cycle-to-chromosome-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($nodes) = path($input_file)->lines( { chomp => 1 } );
$nodes =~ s/[^\d\s]+//xmsg;
my @nodes = split /\s+/xms, $nodes;

printf "(%s)\n", join q{ },
  map { $_ > 0 ? q{+} . $_ : $_ } cycle_to_chromosome(@nodes);

sub cycle_to_chromosome {
    my (@nodes) = @_;    ## no critic (ProhibitReusedNames)

    my @chromosome;
    foreach my $j ( 1 .. scalar @nodes / 2 ) {
        if ( $nodes[ 2 * $j - 2 ] < $nodes[ 2 * $j - 1 ] ) {
            push @chromosome, $nodes[ 2 * $j - 1 ] / 2;
        }
        else {
            push @chromosome, -$nodes[ 2 * $j - 2 ] / 2;
        }
    }

    return @chromosome;
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

cycle-to-chromosome.pl

Cycle To Chromosome

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Cycle To Chromosome.

Input: A sequence I<Nodes> of integers between 1 and 2I<n>.

Output: The chromosome I<Chromosome> containing I<n> synteny blocks resulting
from applying CycleToChromosome to I<Nodes>.

=head1 EXAMPLES

    perl cycle-to-chromosome.pl

    perl cycle-to-chromosome.pl --input_file cycle-to-chromosome-extra-input.txt

    diff <(perl cycle-to-chromosome.pl) cycle-to-chromosome-sample-output.txt

    diff \
        <(perl cycle-to-chromosome.pl \
            --input_file cycle-to-chromosome-extra-input.txt) \
        cycle-to-chromosome-extra-output.txt

    perl cycle-to-chromosome.pl --input_file dataset_8222_5.txt \
        > dataset_8222_5_output.txt

=head1 USAGE

    cycle-to-chromosome.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A sequence I<Nodes> of integers between 1 and 2I<n>".

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
