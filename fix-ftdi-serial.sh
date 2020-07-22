#!/bin/sh -ex

# ensure that this is only device powered up
# (since we don't have serial, we can't address it via serial)


if [ $( lsusb -d 0403:6015 | wc -l ) -eq 1 ] ; then

	echo "FIX serial number to 42"
	./ulx3s-bin/usb-jtag/linux-amd64/ftx_prog --new-serial-number 42 --ignore-crc-error
else
	echo "ERROR: more than one 0403:6015 devices found, leave just 1 powered on"
fi
