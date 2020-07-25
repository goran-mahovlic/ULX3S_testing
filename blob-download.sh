#!/bin/sh -xe

test -e blob/esp32 || mkdir -p blob/esp32
cd blob/esp32

# latest stable idf3 version from https://micropython.org/download/esp32/
test -f esp32-idf3-20191220-v1.12.bin || wget --no-check-certificate https://micropython.org/resources/firmware/esp32-idf3-20191220-v1.12.bin

cd -

test -e blob/fpga || mkdir -p blob/fpga
cd blob/fpga

#wget -m https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_ps2kbd.bit
#wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.bit
#wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.27/ulx3s_12f_minimig_ps2kbd.bit

exit 0

# wget -m -A bit -A tar.gz -A img https://github.com/dok3r/ulx3s-saxonsoc/releases/tag/v2020.04.20/

uhubctl -l 2-5 -p 4 -a 2
sleep 2

# test 1 (20 sec wait)
github.com/kost/ulx3s-minimig/releases/download/v2019.12.27/ulx3s_12f_minimig_usbjoy.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.27/ulx3s_12f_minimig_ps2kbd.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_usbjoy.bit

# test 2
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.27/ulx3s_12f_minimig_ps2kbd.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_ps2kbd.bit

# test 3
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.27/ulx3s_12f_minimig_ps2kbd.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_usbjoy.bit

# test 4 (30 sec wait)
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_usbjoy.bit

# test 5
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_usbjoy.compress.bit
github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_12f_minimig_usbjoy.bit



#wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_25f_minimig_ps2kbd.bit
#wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_45f_minimig_ps2kbd.bit
#wget https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.30/ulx3s_85f_minimig_ps2kbd.bit

# wget -r -m -A bit https://github.com/kost/ulx3s-minimig/releases
