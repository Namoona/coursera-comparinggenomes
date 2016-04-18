#!/usr/bin/env perl

# PODNAME: 2-break-on-genome.pl
# ABSTRACT: 2-Break On Genome

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
my $input_file = '2-break-on-genome-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ( $genome, $indices ) = path($input_file)->lines( { chomp => 1 } );
$genome =~ s/\A [(]//xms;
$genome =~ s/[)] \z//xms;
my @genome = split /[)][(]/xms, $genome;
my @p;
foreach my $chromosome (@genome) {
    $chromosome =~ s/[^\d\s-]+//xmsg;
    my @chromosome = split /\s+/xms, $chromosome;
    push @p, \@chromosome;
}
my ( $i, $i_prime, $j, $j_prime ) = split /,\s/xms, $indices;

@genome = two_break_on_genome( \@p, $i, $i_prime, $j, $j_prime );
my $output = q{};
foreach my $chromosome (@genome) {
    $output .= sprintf '(%s)', join q{ },
      map { $_ > 0 ? q{+} . $_ : $_ } @{$chromosome};
}
printf "%s\n", $output;

sub two_break_on_genome {
    ## no critic (ProhibitReusedNames)
    my ( $p, $i, $i_prime, $j, $j_prime ) = @_;
    ## use critic

    my @edges = colored_edges( @{$p} );
    @edges = two_break_on_genome_graph( \@edges, $i, $i_prime, $j, $j_prime );

    my @p = graph_to_genome(@edges);    ## no critic (ProhibitReusedNames)

    return @p;
}

sub two_break_on_genome_graph {
    ## no critic (ProhibitReusedNames)
    my ( $edges, $i, $i_prime, $j, $j_prime ) = @_;
    ## use critic

    my @limits;
    my $k            = 0;
    my $i_or_j_first = 0;
    foreach my $edge ( @{$edges} ) {
        if ( $edge->[0] == $i ) {    ## no critic (ProhibitCascadingIfElse)
            $i_or_j_first++;
            push @limits, $k;
        }
        elsif ( $edge->[0] == $j_prime ) {
            push @limits, $k;
        }
        elsif ( $edge->[0] == $j ) {
            $i_or_j_first++;
            push @limits, $k;
        }
        elsif ( $edge->[0] == $i_prime ) {
            push @limits, $k;
        }
        $k++;
    }
    if ( $i_or_j_first % 2 ) {

        # New cycle
        ( $edges->[ $limits[0] ]->[1], $edges->[ $limits[1] ]->[1] ) =
          ( $edges->[ $limits[1] ]->[1], $edges->[ $limits[0] ]->[1] );
        my @cycle = splice @{$edges}, $limits[0] + 1, $limits[1] - $limits[0];
        push @{$edges}, @cycle;
    }
    else {
        # Reverse
        ( $edges->[ $limits[0] ]->[1], $edges->[ $limits[1] ]->[0] ) =
          ( $edges->[ $limits[1] ]->[0], $edges->[ $limits[0] ]->[1] );
        my @rev = splice @{$edges}, $limits[0] + 1, $limits[1] - $limits[0] - 1;
        @rev = reverse map { [ $_->[1], $_->[0] ] } @rev;
        splice @{$edges}, $limits[0] + 1, 0, @rev;
    }

    return @{$edges};
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

sub graph_to_genome {
    my (@edges) = @_;

    my @p;    ## no critic (ProhibitReusedNames)

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

sub chromosome_to_cycle {
    my (@chromosome) = @_;

    my @nodes;
    foreach my $j ( 1 .. scalar @chromosome ) {
        my $i = $chromosome[ $j - 1 ];    ## no critic (ProhibitReusedNames)
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

2-break-on-genome.pl

2-Break On Genome

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements 2-Break On Genome.

Input: A genome I<P>, followed by indices I<i>, I<i'>, I<j>, and I<j'>.

Output: The genome I<P'> resulting from applying the 2-break operation
2-BreakOnGenomeGraph(I<GenomeGraph>, I<i>, I<i'>, I<j>, I<j>).

=head1 EXAMPLES

    perl 2-break-on-genome.pl

    perl 2-break-on-genome.pl --input_file 2-break-on-genome-extra-input.txt

    diff <(perl 2-break-on-genome.pl) 2-break-on-genome-sample-output.txt

    diff \
        <(perl 2-break-on-genome.pl \
            --input_file 2-break-on-genome-extra-input.txt) \
        2-break-on-genome-extra-output.txt

    perl 2-break-on-genome.pl --input_file dataset_8224_3.txt \
        > dataset_8224_3_output.txt

=head1 USAGE

    2-break-on-genome.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A genome I<P>, followed by indices I<i>, I<i'>, I<j>,
and I<j'>".

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
