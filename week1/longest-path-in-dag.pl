#!/usr/bin/env perl

# PODNAME: longest-path-in-dag.pl
# ABSTRACT: Longest Path in a DAG

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

use List::Util qw(max);

# Default options
my $input_file = 'longest-path-in-dag-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $source, $sink, @edges ) = path($input_file)->lines( { chomp => 1 } );

my %graph;
foreach my $edge (@edges) {
    next if !$edge;
    my ( $node1, $node2, $weight ) = split /\D+/xms, $edge;
    $graph{$node1}{$node2} = $weight;
}

my ( $length, @path ) = longest_path_in_dag( \%graph, $source, $sink );
printf "%d\n%s\n", $length, join '->', @path;

sub longest_path_in_dag {
    my ( $graph, $source, $sink ) = @_;    ## no critic (ProhibitReusedNames)

    my %is_node;
    my %predescessor_for;
    foreach my $node1 ( keys %{$graph} ) {
        $is_node{$node1} = 1;
        foreach my $node2 ( keys %{ $graph->{$node1} } ) {
            $is_node{$node2} = 1;
            $predescessor_for{$node2}{$node1} = 1;
        }
    }
    my @nodes = sort { $a <=> $b } keys %is_node;

    my @s;
    my @backtrack;
    foreach my $b (@nodes) {
        $s[$b] = undef;
    }
    $s[$source] = 0;
    foreach my $b (@nodes) {
        next if $b <= $source;
        foreach my $a ( keys %{ $predescessor_for{$b} } ) {
            next if !defined $s[$a];
            if ( !defined $s[$b] || $s[$a] + $graph->{$a}{$b} > $s[$b] ) {
                $s[$b]         = $s[$a] + $graph->{$a}{$b};
                $backtrack[$b] = $a;
            }
        }
    }

    my @path = ($sink);    ## no critic (ProhibitReusedNames)
    while ( $path[0] != $source ) {
        unshift @path, $backtrack[ $path[0] ];
    }

    return $s[$sink], @path;
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

longest-path-in-dag.pl

Longest Path in a DAG

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Longest Path in a DAG Problem.

Input: An integer representing the source node of a graph, followed by an
integer representing the sink node of the graph, followed by a list of edges in
the graph.

Output: The length of a longest path in the graph, followed by a longest path.

=head1 EXAMPLES

    perl longest-path-in-dag.pl

    perl longest-path-in-dag.pl --input_file longest-path-in-dag-extra-input.txt

    diff <(perl longest-path-in-dag.pl) longest-path-in-dag-sample-output.txt

    diff \
        <(perl longest-path-in-dag.pl \
            --input_file longest-path-in-dag-extra-input.txt) \
        longest-path-in-dag-extra-output.txt

    perl longest-path-in-dag.pl --input_file dataset_245_7.txt \
        > dataset_245_7_output.txt

=head1 USAGE

    longest-path-in-dag.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "An integer representing the source node of a graph,
followed by an integer representing the sink node of the graph, followed by a
list of edges in the graph".

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
