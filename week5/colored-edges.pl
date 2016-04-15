#!/usr/bin/env perl

# PODNAME: colored-edges.pl
# ABSTRACT: Colored Edges

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
my $input_file = 'colored-edges-sample-input.txt';
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

my ($genome) = path($input_file)->lines( { chomp => 1 } );
$genome =~ s/\A [(]//xms;
$genome =~ s/[)] \z//xms;
my @genome = split /[)][(]/xms, $genome;
my @p;
foreach my $chromosome (@genome) {
    $chromosome =~ s/[^\d\s-]+//xmsg;
    my @chromosome = split /\s+/xms, $chromosome;
    push @p, \@chromosome;
}

my @edges;
foreach my $edge ( colored_edges(@p) ) {
    push @edges, sprintf '(%d, %d)', @{$edge};
}
printf "%s\n", join q{, }, @edges;

sub colored_edges {
    my (@p) = @_;    ## no critic (ProhibitReusedNames)

    my @edges;       ## no critic (ProhibitReusedNames)

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

colored-edges.pl

Colored Edges

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script implements Colored Edges.

Input: A genome I<P>.

Output: The collection of colored edges in the genome graph of I<P> in the form
(I<x>, I<y>).

=head1 EXAMPLES

    perl colored-edges.pl

    perl colored-edges.pl --input_file colored-edges-extra-input.txt

    diff <(perl colored-edges.pl) colored-edges-sample-output.txt

    diff \
        <(perl colored-edges.pl --input_file colored-edges-extra-input.txt) \
        colored-edges-extra-output.txt

    perl colored-edges.pl --input_file dataset_8222_7.txt \
        > dataset_8222_7_output.txt

=head1 USAGE

    colored-edges.pl
        [--input_file FILE]
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

=item B<--input_file FILE>

The input file containing "A genome I<P>".

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
