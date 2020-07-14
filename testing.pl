#!/usr/bin/perl
use warnings;
use strict;

use English;
use File::Slurp;

use Data::Dump qw(dump);

# define manufacturer included in serial number and submit data to
# https://github.com/emard/ulx3s/blob/master/doc/MANUAL.md
my $manufacturer  = 'K';
my $board_version = 'v3.0.8';
my $serial_fmt    = '%05d';

if ( length( $manufacturer . sprintf($serial_fmt,0,0) ) > 6 ) {
	die "serial number must be shorter than 6 chars, decrease \$manufacturer in script!";
}

my $debug = $ENV{DEBUG} || 0; # use DEBUG=1 to enable debug

die "need to run $0 as root\n" unless $UID == 0;

if ( ! -e 'data' ) {
	mkdir 'data'; # we will store dumps there
}

my $power_hubs;
my $hub_loc;

$SIG{CHLD} = "IGNORE";

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

warn "# power_hubs = ",dump($power_hubs) if $debug;

print "Plug in some FPGA boards or power cycle ports using uhubctl!\n";

my $seen_serial; # state machine for serial
my $data; # collected data about this serial

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

		my $serial = $prop->{ID_SERIAL_SHORT} || die "can't find ID_SERIAL_SHORT in prop = ",dump($prop);

		if ( -e "data/$serial/ftx_prog" ) {
			$seen_serial->{$serial} = 2;
			print "SKIP $serial ftx_prog done, go to step 2\n";
		}

		if ( exists $power_hubs->{$hub}->{$port} ) {
			if ( ! exists $seen_serial->{ $serial } ) {
				$seen_serial->{ $serial } = 1;

				print "FOUND $serial $dev on hub $hub port $port from $path\n";
				print "FIXME to power-cycle use: uhubctl -l $hub -p $port -a 2\n";

				my $fpga_size;
				open(my $model, '-|', "openFPGALoader --board=ulx3s --detect --device=$prop->{DEVNAME}");
				while(<$model>) {
					chomp;
					if ( m/model\s+LFE5U-(\d+)/ ) {
						$fpga_size = $1;
						print "FOUND $serial is $fpga_size size\n";
					}
					warn "# $_\n"; # if $debug;
				}
				close($model);

				die "no fpga_size for $serial" unless $fpga_size;

				my @existing_serials = glob "data/$manufacturer*";
				my $next_serial = scalar($#existing_serials) + 1;
				if ( $next_serial == 0 ) {
					$next_serial = 1; # start with 1 not 0
				}
				my $new_serial = $manufacturer . sprintf( $serial_fmt, $next_serial );
				print "NEW SERIAL for $serial is $new_serial\n";

				mkdir "data/$new_serial"; # allocate new serial
				write_file "data/$new_serial/fpga_size", $fpga_size;
				write_file "data/$new_serial/old_serial", $serial;

				$seen_serial->{$new_serial} = 2; # go to next step
				#delete $seen_serial->{$serial} # TODO - do we purge it?

				# fork
				#close($udev);
				if ( fork() ) {
					# parent
					print "BACK to udevadm monitor loop...\n";
					#open($udev, '-|', 'udevadm monitor --udev --subsystem-match tty --property');
				} else {
					# child

					# put new data in FTDI ship
					my $cmd = sprintf( qq{./ulx3s-bin/usb-jtag/linux-amd64/ftx_prog --max-bus-power 500 --manufacturer "FER-RADIONA-EMARD" --product "ULX3S FPGA %02dK %s" --new-serial-number "%s" --old-serial-number "%s" --cbus 2 TxRxLED --cbus 3 SLEEP | tee data/$new_serial/ftx_prog }, $fpga_size, $board_version, $new_serial, $serial );
					print "EXECUTE $cmd\n";
					system $cmd;

					# power cycle
					system "uhubctl -l $hub -p $port -a 2 | tee data/$new_serial/uhubctl";
					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 2 ) { # programmed ftdi

				print "TODO 2 -- data = ",dump( $data ), " seen_serial = ",dump( $seen_serial ), $/;

			} else {
				warn "UNHANDLED seen_serial state ", $seen_serial->{ $serial }, " prop = ",dump($prop), "\ndata $serial = ",dump( $data->{ $serial } );
			}

		} else {
			print "ERROR: $dev on hub $hub port $port NOT POWER CAPABLE!\n";
		}
	} else {
		warn "IGNORE udev: $_\n" if $debug;
	}

}
