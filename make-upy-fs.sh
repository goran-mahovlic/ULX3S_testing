#!/bin/sh -xe

cp blob/esp32/upy-blank.img upy.img
mkdir /tmp/upy
mount upy.img /tmp/upy
cp esp32ecp5/*.py esp32ecp5/*.conf /tmp/upy/
umount /tmp/upy

add_selftest() {
	size=$1
	bit=$2

	cp $bit /tmp/f32c_selftest-$size.bit
	gzip -9 /tmp/f32c_selftest-$size.bit
	cp upy.img upy-$size.img
	mount upy-$size.img /tmp/upy
	mv /tmp/f32c_selftest-$size.bit.gz /tmp/upy

	mv /tmp/upy/main.py /tmp/upy/main.py.template

	cp blob/ulx3s-saxonsoc/v2020.04.20/saxonsoc-ulx3s-linux-$size.bit.gz /tmp/upy/

	ls -al /tmp/upy
	umount /tmp/upy
}

add_selftest 12 ulx3s-bin/fpga/f32c/f32c-12k-v20/ulx3s_v20_12f_f32c_selftest_2ws_89mhz.bit
add_selftest 25 ulx3s-bin/fpga/f32c/f32c-25k-vector-v20/ulx3s_v20_25f_f32c_selftest_2ws_89mhz.bit
add_selftest 45 ulx3s-bin/fpga/f32c/f32c-45k-vector-v20/ulx3s_v20_45f_f32c_selftest_2ws_89mhz.bit
add_selftest 85 ulx3s-bin/fpga/f32c/f32c-85k-vector-v20/ulx3s_v20_85f_f32c_selftest_2ws_89mhz.bit

rmdir /tmp/upy
