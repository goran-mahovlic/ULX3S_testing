#!/bin/sh -e

test -z "$1" && echo "Usage: $0 /dev/mmcblk0" && exit 1

gzip -cd blob/ulx3s-saxonsoc/v2020.04.20/saxonsoc-sdimage.raw.gz | dd status=progress bs=1M of=$1
