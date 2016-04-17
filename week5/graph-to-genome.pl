#!/usr/bin/env perl

# PODNAME: graph-to-genome.pl
# ABSTRACT: Graph To Genome

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-15

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = 'graph-to-genome-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($colored_edges) = path($input_file)->lines( { chomp => 1 } );
$colored_edges =~ s/\A [(]//xms;
$colored_edges =~ s/[)] \z//xms;
my @colored_edges = split /[)],\s[(]/xms, $colored_edges;
@colored_edges = map { [ split /,\s/xms ] } @colored_edges;

my @genome = graph_to_genome(@colored_edges);
my $output = q{};
foreach my $chromosome (@genome) {
    $output .= sprintf '(%s)', join q{ },
      map { $_ > 0 ? q{+} . $_ : $_ } @{$chromosome};
}
printf "%s\n", $output;

sub graph_to_genome {
    my (@edges) = @_;

    my @p;

    my @cycle;
    foreach my $edge (@edges) {
        push @cycle, @{$edge};

        # Complete cycle if first and last numbers are paired
        if ( abs( $cycle[0] - $cycle[-1] ) == 1
            && int( $cycle[0] / 2 ) != int( $cycle[-1] / 2 ) )
        {
            unshift @cycle, $cycle[-1];
            push @p, [ cycle_to_chromosome(@cycle) ];
            @cycle = ();
        }
    }

    return @p;
}

sub cycle_to_chromosome {
    my (@nodes) = @_;

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

graph-to-genome.pl

Graph To Genome

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Graph To Genome.

Input: The colored edges I<ColoredEdges> of a genome graph.

Output: The genome I<P> corresponding to this genome graph.

=head1 EXAMPLES

    perl graph-to-genome.pl

    perl graph-to-genome.pl --input_file graph-to-genome-extra-input.txt

    diff <(perl graph-to-genome.pl) graph-to-genome-sample-output.txt

    diff \
        <(perl graph-to-genome.pl \
            --input_file graph-to-genome-extra-input.txt) \
        graph-to-genome-extra-output.txt

    perl graph-to-genome.pl --input_file dataset_8222_8.txt \
        > dataset_8222_8_output.txt

=head1 USAGE

    graph-to-genome.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "The colored edges I<ColoredEdges> of a genome graph".

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
