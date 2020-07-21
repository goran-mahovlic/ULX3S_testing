#!/bin/sh -xe

test -e blob/esp32 || mkdir -p blob/esp32
cd blob/esp32

# latest stable idf3 version from https://micropython.org/download/esp32/
test -f esp32-idf3-20191220-v1.12.bin || wget --no-check-certificate https://micropython.org/resources/firmware/esp32-idf3-20191220-v1.12.bin

cd -

test -e blob/fpga || mkdir -p blob/fpga
cd blob/fpga

wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_ps2kbd.bit
wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_25f_minimig_ps2kbd.bit
wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_45f_minimig_ps2kbd.bit
wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_85f_minimig_ps2kbd.bit
