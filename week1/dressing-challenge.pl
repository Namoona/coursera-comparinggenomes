#!/usr/bin/env perl

# PODNAME: dressing-challenge.pl
# ABSTRACT: Dressing Challenge

## Author     : Ian Sealy
## Maintainer : Ian Sealy
## Created    : 2016-03-18

use warnings;
use strict;
use autodie;
use Getopt::Long;
use Pod::Usage;
use Carp;
use Path::Tiny;
use version; our $VERSION = qv('v0.1.0');

use Readonly;
use Math::Combinatorics;

# Constants
Readonly our @NODES => qw(tights leotard shorts boots gloves cape hood belt);
Readonly our @RULES => (
    [qw(tights leotard)], [qw(tights boots)],
    [qw(leotard shorts)], [qw(shorts boots)],
    [qw(leotard gloves)], [qw(leotard cape)],
    [qw(cape hood)],      [qw(shorts belt)],
);

# Default options
my ( $debug, $help, $man );

# Get and check command line options
get_and_check_options();

printf "%d\n", dressing_challenge();

sub dressing_challenge {
    my $num_valid = 0;

    my @perms = permute(@NODES);
    foreach my $perm (@perms) {
        my %order;
        my $i = 0;
        foreach my $node ( @{$perm} ) {
            $i++;
            $order{$node} = $i;
        }
        my $is_valid = 1;
        foreach my $rule (@RULES) {
            ## no critic (ProhibitAmbiguousNames)
            my ( $first, $second ) = @{$rule};
            ## use critic
            if ( $order{$first} > $order{$second} ) {
                $is_valid = 0;
                last;
            }
        }
        if ($is_valid) {
            $num_valid++;
        }
    }

    return $num_valid;
}

# Get and check command line options
sub get_and_check_options {

    # Get options
    GetOptions(
        'debug' => \$debug,
        'help'  => \$help,
        'man'   => \$man,
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

dressing-challenge.pl

Dressing Challenge

=head1 VERSION

version 0.1.0

=head1 DESCRIPTION

This script solves the Dressing Challenge Problem.

Output: The number of topological orderings.

=head1 EXAMPLES

    perl dressing-challenge.pl

=head1 USAGE

    dressing-challenge.pl
        [--debug]
        [--help]
        [--man]

=head1 OPTIONS

=over 8

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
