#!/bin/sh -xe

apt-get install uhubctl libdata-dump-perl libfile-slurp-perl libdevice-serialport-perl python python-serial python3 python3-serial

# use for fujprog, ftx_prog and friends
dpkg -l ulx3s-toolchain || ( wget https://github.com/alpin3/ulx3s/releases/download/v2020.07.12/ulx3s-toolchain_2020.07.12-2_amd64.deb && dpkg -i ulx3s-toolchain_*.deb )
