#!/bin/sh -xe

test -e blob || mkdir blob
cd blob

# latest stable idf3 version from https://micropython.org/download/esp32/
wget --no-check-certificate https://micropython.org/resources/firmware/esp32-idf3-20191220-v1.12.bin
