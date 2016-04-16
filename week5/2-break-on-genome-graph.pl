#!/usr/bin/env perl

# PODNAME: 2-break-on-genome-graph.pl
# ABSTRACT: 2-Break On Genome Graph

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-04-16

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

# Default options
my $input_file = '2-break-on-genome-graph-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $colored_edges, $indices ) = path($input_file)->lines( { chomp => 1 } );
$colored_edges =~ s/\A [(]//xms;
$colored_edges =~ s/[)] \z//xms;
my @colored_edges = split /[)],\s[(]/xms, $colored_edges;
@colored_edges = map { [ split /,\s/xms ] } @colored_edges;
my ( $i, $i_prime, $j, $j_prime ) = split /,\s/xms, $indices;

my @edges;
foreach my $edge (
    two_break_on_genome_graph( \@colored_edges, $i, $i_prime, $j, $j_prime ) )
{
    push @edges, sprintf '(%d, %d)', @{$edge};
}
printf "%s\n", join q{, }, @edges;

sub two_break_on_genome_graph {
    ## no critic (ProhibitReusedNames)
    my ( $edges, $i, $i_prime, $j, $j_prime ) = @_;
    ## use critic

    @{$edges} = grep { $_->[0] != $i && $_->[1] != $i } @{$edges};
    @{$edges} = grep { $_->[0] != $j && $_->[1] != $j } @{$edges};
    push @{$edges}, [ $i,       $j ];
    push @{$edges}, [ $i_prime, $j_prime ];

    return @{$edges};
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

2-break-on-genome-graph.pl

2-Break On Genome Graph

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements 2-Break On Genome Graph.

Input: The colored edges of a genome graph I<GenomeGraph>, followed by indices
I<i>, I<i'>, I<j>, and I<j'>.

Output: The colored edges of the genome graph resulting from applying the
2-break operation 2-BreakOnGenomeGraph(I<GenomeGraph>, I<i>, I<i'>, I<j>,
I<j'>).

=head1 EXAMPLES

    perl 2-break-on-genome-graph.pl

    perl 2-break-on-genome-graph.pl \
        --input_file 2-break-on-genome-graph-extra-input.txt

    diff <(perl 2-break-on-genome-graph.pl) \
        2-break-on-genome-graph-sample-output.txt

    diff \
        <(perl 2-break-on-genome-graph.pl \
            --input_file 2-break-on-genome-graph-extra-input.txt) \
        2-break-on-genome-graph-extra-output.txt

    perl 2-break-on-genome-graph.pl --input_file dataset_8224_2.txt \
        > dataset_8224_2_output.txt

=head1 USAGE

    2-break-on-genome-graph.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "The colored edges of a genome graph I<GenomeGraph>,
followed by indices I<i>, I<i'>, I<j>, and I<j'>".

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
