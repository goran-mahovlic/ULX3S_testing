# ULX3S_testing

> This project is intended to be used on Debian buster. If you don't have
> Debian or don't want to pollute your installation you can examine `docker`
> directory and use docker image instead.

After cloning repository and submodules run scripts as root:

    # download Debian dependencies
    ./debian-install.sh

You will want to edit `testing.pl` script to specify single letter prefix
of serial number to dentote manufacturer. By default it is `K`:

    my $manufacturer  = 'K'; # single letter prefix

You will also want to update board version:

    my $board_version = 'v3.0.8';    

Chaning board version will require to submit patch to ujprog and fujprog
so that new version is supported at:

https://github.com/f32c/tools/tree/master/ujprog

https://github.com/kost/fujprog


To run test of ULX3S after production run `testing.pl` as root.

If you don't want to start with serial 1, create directory with serial number
which is one less than first serial number like:

    mkdir -p data/K00042

if you want first serial number to be `K00043`


# Helper scripts in this repository

## ./make-upy-fs.sh

Create micropython filesystems for esp32 with selftest f32c bit. It will be
called automatically from `testing.pl` but if you change files included in it
you can also run it manually.

## ./retest-serial.sh serial

This script will cleanup files from `data/serial` and re-run programming
of board with this serial number




# Steps performed during testing


## step 1

FTDI programming

    usb-jtag/linux-amd64/ftx_prog --max-bus-power 500
    usb-jtag/linux-amd64/ftx_prog --manufacturer "FER-RADIONA-EMARD"
    usb-jtag/linux-amd64/ftx_prog --product "ULX3S FPGA 12K v3.0.8"
    usb-jtag/linux-amd64/ftx_prog --new-serial-number 120001
    usb-jtag/linux-amd64/ftx_prog --cbus 2 TxRxLED
    usb-jtag/linux-amd64/ftx_prog --cbus 3 SLEEP

power-cycle board using `uhubctl`

## step 2

FLASH passthru bitstrem based on CHIP_ID

https://github.com/emard/ulx3s-bin/tree/master/fpga/passthru



## step 3

power-cycle board



## step 4

ESP32 BURN FUSE

https://github.com/emard/ulx3s-bin/blob/master/esp32/burn-efuse-flash-3v3.sh



ESP32 flash Micropython

https://github.com/emard/esp32ecp5

Normal procedure is:

    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin

However, we are installing pre-populated filesystem created using `make-upy-fs.sh`

    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin 0x200000 upy.img


    
ESP32 start selftest from ESP32 filesystem (we can't touch SD card from micropython because
if we do we can't test it)

This files (gzipped) are part of micropython filesystem created by `make-upy-fs.sh`
which include bitstream that will be used in following steps to flash FPGA since
this is fastest way to start bitstream on ULX3S


## step 5

This will load selftest bitstream and start it

https://github.com/emard/ulx3s-bin/blob/master/fpga/f32c/f32c-12k-v20/f32c_ulx3s_v20_12k_selftest_100mhz_ws2_flash.img

    >>> import ecp5
    >>> ecp5.prog("f32c_selftest-25.bit.gz")
    I (78530) gpio: GPIO[23]| InputEn: 0| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:0
    I (78530) gpio: GPIO[19]| InputEn: 0| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:0
    I (78540) gpio: GPIO[18]| InputEn: 0| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:0
    
    m32l>

After selftest is started wi will load slightly modified f32c binary which will test all
parts of board just once, wait for each key to be pressed and depressed to be sure that
all of them are working and finally wait for HDMI EDID (so you have to connect monitor
to pass this step).

Selftest used is available at

https://github.com/dpavlin/Arduino-projects/tree/master/c2_ulx3s_test

and is modified version of original selftest available from

https://github.com/f32c/arduino/tree/master/libraries/Compositing/examples/c2_ulx3s_test

It will be loaded over serial port using

   ./ulx3s-bin/fpga/f32c/f32cup.py ./ulx3s-bin/fpga/f32c/f32c-bin/selftest-mcp7940n.bin



## step 8

There used to be more steps, but they where removed since all bitstreams are now part of esp32 filesystem.

This step uses SaxonSoc which upstream is https://github.com/SpinalHDL/SaxonSoc
which was ported to ULX3S by @lawrie

We are using @kost build from https://github.com/dok3r/ulx3s-saxonsoc/releases
and requires sdcard with rootfs which can be generated using `make-sdcard.sh`

:warning: Current version of saxonsoc as configured in this repository for 85k is for boards with 32Mb of
RAM and will not work with boards with 64Mb of RAM. To fix this, you will need to download
https://github.com/dok3r/ulx3s-saxonsoc/releases/download/v2020.04.20/saxonsoc-ulx3s-linux-85-64mem.bit
and compress it into `blob/ulx3s-saxonsoc/v2020.04.20/saxonsoc-ulx3s-linux-85.bit.gz`


## step 9

Start success bitstream which will indicate size of FPGA with LEDs to allow easy sorting into separate
boxes

## step 10

dummy step to report that testing is done


# TODO

- [x] no serial programming by default (use PRODUCTION=1 for FTDI programming)
- [x] force serial number to program for this board
- [ ] document docker image usage


