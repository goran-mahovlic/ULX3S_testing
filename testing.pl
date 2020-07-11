#!/usr/bin/perl
use warnings;
use strict;

use English;

use Data::Dump qw(dump);

my $debug = $ENV{DEBUG} || 0; # use DEBUG=1 to enable debug

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

open(my $udev, '-|', 'udevadm monitor --udev --subsystem-match tty --property');
while(<$udev>) {
	chomp;
	if (m/\S+ add\s+(\S+) \(tty\)/ ) {
		my $path = $1;
		my @p = split(/\//, $path);
		my $dev  = $p[-1];
		my $port = $p[-5];
		my $hub  = $p[-6];
		$port =~ s/^$hub\.//; # strip hub from port identifier

		# read property
		my $prop;
		while(<$udev>) {
			chomp;
			last if $_ eq '';
			my ( $name, $val ) = split(/=/,$_,2);
			$prop->{$name} = $val;
		}

		print "# prop = ",dump($prop);


		if ( exists $power_hubs->{$hub}->{$port} ) {
			print "FOUND $dev on hub $hub port $port from $path\n";
			print "FIXME to power-cycle use: uhubctl -l $hub -p $port -a 2\n";
		} else {
			print "ERROR: $dev on hub $hub port $port NOT POWER CAPABLE!\n";
		}
	} else {
		warn "IGNORE udev: $_\n" if $debug;
	}

}
