#!/usr/bin/env perl

# PODNAME: 2-break.pl
# ABSTRACT: 2-Break Distance

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
my $input_file = '2-break-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $p, $q ) = path($input_file)->lines( { chomp => 1 } );
my @p = parse_genome($p);
my @q = parse_genome($q);

printf "%d\n", distance( \@p, \@q );

sub parse_genome {
    my ($genome) = @_;

    $genome =~ s/\A [(]//xms;
    $genome =~ s/[)] \z//xms;
    my @genome;
    foreach my $chromosome ( split /[)][(]/xms, $genome ) {
        $chromosome =~ s/[^\d\s-]+//xmsg;
        my @chromosome = split /\s+/xms, $chromosome;
        push @genome, \@chromosome;
    }

    return @genome;
}

sub distance {
    my ( $p, $q ) = @_;    ## no critic (ProhibitReusedNames)

    return blocks( @{$p} ) - scalar cycles( $p, $q );
}

sub blocks {
    my (@genome) = @_;

    my $blocks = 0;
    foreach my $chromosome (@genome) {
        $blocks += scalar @{$chromosome};
    }

    return $blocks;
}

sub cycles {
    my ( $p, $q ) = @_;    ## no critic (ProhibitReusedNames)

    my @red_edges  = colored_edges( @{$p} );
    my @blue_edges = colored_edges( @{$q} );

    my @cycles;
    my %undiscovered = map { $_ => 1 } ( 1 .. scalar @red_edges * 2 );
    while ( keys %undiscovered ) {
        my $node = ( sort keys %undiscovered )[0];
        push @cycles,
          [ cycle( \@red_edges, \@blue_edges, \%undiscovered, $node ) ];
    }

    return @cycles;
}

sub cycle {
    my ( $red_edges, $blue_edges, $undiscovered, $node ) = @_;

    my @cycle = ();

    while (1) {
        last if !exists $undiscovered->{$node};
        delete $undiscovered->{$node};
        my ($red_edge) =
          grep { $_->[0] == $node || $_->[1] == $node } @{$red_edges};
        push @cycle, $red_edge;
        $node = $red_edge->[0] == $node ? $red_edge->[1] : $red_edge->[0];
        delete $undiscovered->{$node};
        my ($blue_edge) =
          grep { $_->[0] == $node || $_->[1] == $node } @{$blue_edges};
        push @cycle, $blue_edge;
        $node = $blue_edge->[0] == $node ? $blue_edge->[1] : $blue_edge->[0];
    }

    return @cycle;
}

sub colored_edges {
    my (@p) = @_;    ## no critic (ProhibitReusedNames)

    my @edges;

    foreach my $chromosome (@p) {
        my @nodes = chromosome_to_cycle( @{$chromosome} );
        push @nodes, $nodes[0];
        foreach my $j ( 1 .. scalar @{$chromosome} ) {
            push @edges, [ $nodes[ 2 * $j - 1 ], $nodes[ 2 * $j ] ];
        }
    }

    return @edges;
}

sub chromosome_to_cycle {
    my (@chromosome) = @_;

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

2-break.pl

2-Break Distance

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the 2-Break Distance Problem.

Input: Genomes I<P> and I<Q>.

Output: The 2-break distance I<d>(I<P>, I<Q>).

=head1 EXAMPLES

    perl 2-break.pl

    perl 2-break.pl --input_file 2-break-extra-input.txt

    diff <(perl 2-break.pl) 2-break-sample-output.txt

    diff \
        <(perl 2-break.pl --input_file 2-break-extra-input.txt) \
        2-break-extra-output.txt

    perl 2-break.pl --input_file dataset_288_4.txt > dataset_288_4_output.txt

=head1 USAGE

    2-break.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "Genomes I<P> and I<Q>".

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
