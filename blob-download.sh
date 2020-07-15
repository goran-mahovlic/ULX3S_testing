#!/bin/sh -xe

test -e blob/esp32 || mkdir -p blob/esp32
cd blob/esp32

# latest stable idf3 version from https://micropython.org/download/esp32/
wget --no-check-certificate https://micropython.org/resources/firmware/esp32-idf3-20191220-v1.12.bin
