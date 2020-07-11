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

open(my $udev, '-|', 'udevadm monitor --kernel --subsystem-match usb-serial');
while(<$udev>) {
	chomp;
	if (m/\S+ bind\s+(\S+) \(usb-serial\)/ ) {
		my $path = $1;
		my @p = split(/\//, $path);
		my $dev  = $p[-1];
		my $port = $p[-3];
		my $hub  = $p[-4];
		$port =~ s/^$hub\.//; # strip hub from port identifier
		if ( exists $power_hubs->{$hub}->{$port} ) {
			print "FOUND $dev on hub $hub port $port from $path\n";
			print "FIXME to power-cycle use: uhubctl -l $hub -p $port -a 2\n";
		} else {
			print "ERROR: $dev on hub $hub port $port NOT POWER CAPABLE!\n";
		}
	} else {
		warn "IGNORE udev: $_\n";
	}

}
