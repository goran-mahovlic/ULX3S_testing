#!/bin/sh -e

# compress bitstream

test -z "$1" && echo "Usage: hardware.bit" && exit 1

mv $1 /tmp/$1.orig
ecpunpack /tmp/$1.orig /tmp/$1.orig.conf
ecppack --compress /tmp/$1.orig.conf $1
