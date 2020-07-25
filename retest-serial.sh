#!/bin/sh -e

test -z "$1" && echo "Usage: $0 serial" && exit 1

if [ -d data/$1 ] ; then
	tar cfp /tmp/$1.tar.gz data/$1/
	rm -v data/$1/[2-9]*
	test -f data/$1/child_pid && rm data/$1/child_pid
	echo "Backup created:"
	ls -al /tmp/$1.tar.gz
else
	echo "No $1 serial!"
	exit 1
fi
