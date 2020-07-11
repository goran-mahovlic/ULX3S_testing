#!/usr/bin/perl
use warnings;
use strict;

use English;

use Data::Dump qw(dump);

die "need to run $0 as root\n" unless $UID == 0;

my $power_hubs;
my $hub_loc;

# collect hub locations and ports which are powered
open(my $uhubctl, '-|', 'uhubctl');
while(<$uhubctl>) {
	chomp;
	if ( m/Current status for hub (\S+)/ ) {
		$hub_loc = $1;
		$power_hubs->{$hub_loc} = {};
	} elsif ( m/^\s+Port (\d+): \S+ power/ ) {
		$power_hubs->{$hub_loc}->{ $1 }++;

	}
}
close($uhubctl);

warn "# power_hubs = ",dump($power_hubs);
