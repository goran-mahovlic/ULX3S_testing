#!/bin/sh -xe

test -z "$1" && echo "usage: $0 serial" && exit 1

../ulx3s-bin/usb-jtag/linux-amd64/ftx_prog --old-serial-number $1 --save $1 | tee $1.txt

