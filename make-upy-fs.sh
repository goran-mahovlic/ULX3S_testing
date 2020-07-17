#!/bin/sh -xe

cp blob/esp32/upy-blank.img upy.img
mkdir /tmp/upy
mount upy.img /tmp/upy
cp esp32ecp5/*.py esp32ecp5/*.conf /tmp/upy/
umount /tmp/upy
rmdir /tmp/upy

