#!/usr/bin/perl
use warnings;
use strict;

use English;
use File::Slurp;
use Device::SerialPort;

use Data::Dump qw(dump);
use autodie;

# define manufacturer included in serial number and submit data to
# https://github.com/emard/ulx3s/blob/master/doc/MANUAL.md
my $manufacturer  = 'K'; # single letter prefix
my $board_version = 'v3.0.8';
my $serial_fmt    = '%05d';

if ( length( $manufacturer . sprintf($serial_fmt,0) ) > 6 ) {
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
$|=1; # flush STDOUT

my $ser_dev;
my $ser_log;

sub serial_open {
	my ( $dev, $log ) = @_;

	$ser_dev = new Device::SerialPort($dev) || die "can't open $dev";
	$ser_dev->baudrate(115200) || die;
	$ser_dev->parity("none") || die;
	$ser_dev->databits(8) || die;
	$ser_dev->stopbits(1) || die;
	$ser_dev->handshake("none") || die;

	$ser_dev->read_char_time(0);
	$ser_dev->read_const_time(500);

	$ser_dev->user_msg(1);
	$ser_dev->error_msg(1);

	$ser_dev->write_settings || die;

	open($ser_log, '>', $log);
	print "DEBUG serial_open($dev,$log)\n" if $debug;
}

sub serial_read {
	my ($count, $in) = (0,'');
	while ( $count == 0 ) {
		($count, $in) = $ser_dev->read(1024);
		die "stop serial_read" unless defined $count;
		warn "<<[$count] ",dump($in) if $debug && $count > 0;
	}
	print "$in\n";
	print $ser_log "serial<< $in";
	return $in;
}

sub serial_write {
	my ($out, $stop_at) = @_;
	$stop_at //= '> $'; # prompt
	$ser_dev->write($out . "\r");
	print $ser_log "serial>> $out\n";
	my $in = '';
	while ( $in !~ m/${stop_at}/ ) { # wait for prompt
		$in .= serial_read;
	}
	return $in;
}

sub serial_close {
	$ser_dev->close;
	close($ser_log);
}

# collect hub locations and ports which are powered
open(my $uhubctl, '-|', 'uhubctl');
while(<$uhubctl>) {
	chomp;
	if ( m/Current status for hub (\S+)/ ) {
		$hub_loc = $1;
		$power_hubs->{$hub_loc} = {};
	} elsif ( m/^\s+Port (\d+): \S+/ ) {
		$power_hubs->{$hub_loc}->{ $1 }++;

	}
}
#close($uhubctl); # can't close allready exited

warn "# power_hubs = ",dump($power_hubs) if $debug;

print "Plug in some FPGA boards or power cycle ports using uhubctl!\n";

my $seen_serial; # state machine for serial
my $data; # collected data about this serial
my @powercycle_usb;

open(my $udev, '-|', 'udevadm monitor --udev --subsystem-match tty --property');
while(<$udev>) {
	chomp;
	if (m/\S+ add\s+(\S+) \(tty\)/ ) {
		warn "DEBUG $_\n" if $debug;
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
			warn "DEBUG prop $_\n" if $debug;
			last if $_ eq '';
			my ( $name, $val ) = split(/=/,$_,2);
			$prop->{$name} = $val;
		}

		my $serial = $prop->{ID_SERIAL_SHORT};
		if ( ! defined $serial ) {
			print "ERROR: can't find ID_SERIAL_SHORT in prop = ",dump($prop);
			print "SKIPPING THIS BOARD: plug it alone and run ./fix-ftdi-serial.sh";
			next;
		}
		my $dev = $prop->{DEVNAME} || die "no DEVNAME in prop = ",dump($prop);

		# steps here go in reverse order to end up in last one
		if ( -e "data/$serial/child_pid" ) {
			print "WORKING $serial child_pid = ", read_file("data/$serial/child_pid"), "\n";
			next;
		} elsif ( -e "data/__$serial/child_pid" ) {
			print "WORKING __$serial child_pid = ", read_file("data/__$serial/child_pid"), "\n";
			next;
		} elsif ( -e "data/$serial/70.amiga-output" && $seen_serial->{$serial} < 8) {
			print "SKIP $serial amiga done\n";
			$seen_serial->{$serial} = 8;
		} elsif ( -e "data/$serial/60.amiga" && $seen_serial->{$serial} < 7) {
			print "SKIP $serial amiga programmed\n";
			$seen_serial->{$serial} = 7;
		} elsif ( -e "data/$serial/50.f32c-ecp5-prog" && $seen_serial->{$serial} < 6) {
			print "SKIP $serial selftest done\n";
			$seen_serial->{$serial} = 6;
		} elsif ( -e "data/$serial/40.esp32-flash-3v3" && $seen_serial->{$serial} < 5) {
			print "SKIP $serial esp32 flash 3v3 fuse done\n";
			$seen_serial->{$serial} = 5;
		} elsif ( -e "data/$serial/30.uhubctl" && $seen_serial->{$serial} < 4) {
			print "SKIP $serial reset after passthru programming done\n";
			$seen_serial->{$serial} = 4;
		} elsif ( -e "data/$serial/20.passthru" && $seen_serial->{$serial} < 3) {
			print "SKIP $serial passthru done\n";
			$seen_serial->{$serial} = 3;
		} elsif ( -e "data/$serial/10.ftx_prog" && $seen_serial->{$serial} < 2) {
			$seen_serial->{$serial} = 2;
			print "SKIP $serial ftx_prog done\n";
		}

		if ( exists $power_hubs->{$hub}->{$port} ) {
			if ( ! exists $seen_serial->{ $serial } ) {
				# 1: program FTDI

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
				#close($model);

				die "no fpga_size for $serial" unless $fpga_size;

				my @existing_serials = sort glob "data/$manufacturer*";
				my $next_serial = $existing_serials[-1]; # last
				$next_serial =~ s{^data/\D+}{}; # remove prefix and manufacturer
				$next_serial++; # increase by 1
				if ( $next_serial == 0 ) {
					$next_serial = 1; # start with 1 not 0
				}
				my $new_serial = $manufacturer . sprintf( $serial_fmt, $next_serial );
				print "NEW SERIAL for $serial is $new_serial\n";

				mkdir "data/__$serial";
				mkdir "data/$new_serial"; # allocate new serial
				write_file "data/$new_serial/fpga_size", $fpga_size;
				write_file "data/$new_serial/old_serial", $serial;


				# fork
				if ( my $pid = fork() ) {
					# parent
					write_file "data/__$serial/child_pid", $pid;
					write_file "data/$new_serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					# child

					# put new data in FTDI ship
					my $cmd = sprintf( qq{./ulx3s-bin/usb-jtag/linux-amd64/ftx_prog --max-bus-power 500 --manufacturer "FER-RADIONA-EMARD" --product "ULX3S FPGA %02dK %s" --new-serial-number "%s" --old-serial-number "%s" --cbus 2 TxRxLED --cbus 3 SLEEP | tee data/$new_serial/10.ftx_prog }, $fpga_size, $board_version, $new_serial, $serial );
					print "EXECUTE $cmd\n";
					system $cmd;

					unlink "data/$new_serial/child_pid";

					# remove old serial left-over
					unlink "data/__$serial/child_pid";
					rmdir "data/__$serial";
					delete $seen_serial->{$serial};

					# power cycle
					system "uhubctl -l $hub -p $port -a 2 | tee data/$new_serial/11.uhubctl";
					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 2 ) {
				# 2: programmed ftdi now flash passthru

				print "STEP 2 -- seen_serial = ",dump( $seen_serial ), "\nprop = ",dump($prop), "\n" if $debug;

				my $fpga_size = read_file "data/$serial/fpga_size";
				my @bit_files = glob "ulx3s-bin/fpga/passthru/*$fpga_size*/*$fpga_size*.bit";
				if ( $#bit_files != 0 ) {
					print "found more than one bit file for $fpga_size, using first one";
				}
				my $bit = $bit_files[0];

				my $cmd = "openFPGALoader --board=ulx3s --device=$prop->{DEVNAME} --write-flash $bit | tee data/$serial/20.passthru";
				print "EXECUTE $cmd\n";
				if ( my $pid = fork() ) {
					# parent
					write_file "data/$serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					unlink "data/$serial/child_pid";

					system $cmd;
					# this command will re-plug usb, so next state is power cycle
					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 3 ) {
				if ( my $pid = fork() ) {
					# parent
					write_file "data/$serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					unlink "data/$serial/child_pid";

					system "uhubctl -l $hub -p $port -a 2 | tee data/$serial/30.uhubctl";
					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 4 ) {
				if ( my $pid = fork() ) {
					# parent
					write_file "data/$serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					my $cmd = "./ulx3s-bin/esp32/serial-uploader/espefuse.py --do-not-confirm --port $dev set_flash_voltage 3.3V | tee data/$serial/40.esp32-flash-3v3";
					print "EXECUTE $cmd\n";
					system $cmd;

					my $fpga_size = read_file "data/$serial/fpga_size";
					$cmd = "./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port $dev --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin 0x200000 upy-$fpga_size.img | tee data/$serial/41.esp32-micropython";
					print "EXECUTE $cmd\n";
					system $cmd;

					unlink "data/$serial/child_pid";

					system "uhubctl -l $hub -p $port -a 2 | tee data/$serial/42.uhubctl";
					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 5 ) {
				if ( my $pid = fork() ) {
					# parent
					write_file "data/$serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					sleep 1;

					my $fpga_size = read_file "data/$serial/fpga_size";

					serial_open($dev, "data/$serial/50.f32c-ecp5-prog");

					sleep 2; # wait for esp32 to boot

					serial_write("\r\r"); # invoke prompt

					serial_write("import ecp5");
					serial_write("ecp5.prog('f32c_selftest-$fpga_size.bit.gz')");
					serial_close;

					system "./ulx3s-bin/fpga/f32c/f32cup.py blob/f32c/c2_ulx3s_test.ino.bin | tee data/$serial/51.f32c-selftest";

					serial_open($dev, "data/$serial/52.f32c-selftest");

					# all_ok=7 = edid ok
					# all_ok=6 = everthing except EDID
					serial_write("\r", 'all_ok=7');
					serial_close;

					unlink "data/$serial/child_pid";

					system "uhubctl -l $hub -p $port -a 2 | tee data/$serial/53.uhubctl";

					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 6 ) {
				if ( my $pid = fork() ) {
					# parent
					write_file "data/$serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					my $fpga_size = read_file "data/$serial/fpga_size";
					my $cmd = "./blob/fujprog -S $serial blob/fpga/ulx3s_${fpga_size}f_minimig_ps2kbd.bit | tee data/$serial/60.amiga";
					#my $cmd = "openFPGALoader --board=ulx3s --device=$dev --write-sram blob/fpga/ulx3s_${fpga_size}f_minimig_ps2kbd.bit | tee data/$serial/60.amiga";
					print "EXECUTE: $cmd\n";
					system "$cmd";

					unlink "data/$serial/child_pid";

					exit 0;
				}

			} elsif ( $seen_serial->{ $serial } == 7 ) {
				if ( my $pid = fork() ) {
					# parent
					write_file "data/$serial/child_pid", $pid;
					print "BACK to udevadm monitor loop... child_pid = $pid\n";
				} else {
					print "Amiga output on $dev...\n";
					serial_open($dev, "data/$serial/70.amiga-output");

					eval {
						# forever, it will die on board uplug
						while (1) {
							serial_read;
						}
					};

					unlink "data/$serial/child_pid";

					exit 0; # will never be reached
				}
			} elsif ( $seen_serial->{ $serial } == 8 ) {
				print "TEST OK for $serial, unplug and put into bag\n";
			} else {
				warn "UNHANDLED seen_serial $serial state ", $seen_serial->{ $serial }, " prop = ",dump($prop), "\ndata $serial = ",dump( $data->{ $serial } );
			}

		} else {
			print "ERROR: $dev on hub $hub port $port NOT POWER CAPABLE!\n";
		}
	} else {
		warn "IGNORE udev: $_\n" if $debug;
	}

}
