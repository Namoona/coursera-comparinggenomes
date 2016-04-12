#!/usr/bin/env perl

# PODNAME: chromosome-to-cycle.pl
# ABSTRACT: Chromosome To Cycle

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
my $input_file = 'chromosome-to-cycle-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($chromosome) = path($input_file)->lines( { chomp => 1 } );
$chromosome =~ s/[^\d\s-]+//xmsg;
my @chromosome = split /\s+/xms, $chromosome;

printf "(%s)\n", join q{ }, chromosome_to_cycle(@chromosome);

sub chromosome_to_cycle {
    my (@chromosome) = @_;    ## no critic (ProhibitReusedNames)

    my @nodes;
    foreach my $j ( 1 .. scalar @chromosome ) {
        my $i = $chromosome[ $j - 1 ];
        if ( $i > 0 ) {
            $nodes[ 2 * $j - 2 ] = 2 * $i - 1;
            $nodes[ 2 * $j - 1 ] = 2 * $i;
        }
        else {
            ## no critic (ProhibitMagicNumbers)
            $nodes[ 2 * $j - 2 ] = -2 * $i;
            $nodes[ 2 * $j - 1 ] = -2 * $i - 1;
            ## use critic
        }
    }

    return @nodes;
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

chromosome-to-cycle.pl

Chromosome To Cycle

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Chromosome To Cycle.

Input: A chromosome I<Chromosome> containing I<n> synteny blocks.

Output: The sequence I<Nodes> of integers between 1 and 2I<n> resulting from
applying ChromosomeToCycle to I<Chromosome>.

=head1 EXAMPLES

    perl chromosome-to-cycle.pl

    perl chromosome-to-cycle.pl --input_file chromosome-to-cycle-extra-input.txt

    diff <(perl chromosome-to-cycle.pl) chromosome-to-cycle-sample-output.txt

    diff \
        <(perl chromosome-to-cycle.pl \
            --input_file chromosome-to-cycle-extra-input.txt) \
        chromosome-to-cycle-extra-output.txt

    perl chromosome-to-cycle.pl --input_file dataset_8222_4.txt \
        > dataset_8222_4_output.txt

=head1 USAGE

    chromosome-to-cycle.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A chromosome I<Chromosome> containing I<n> synteny
blocks".

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
