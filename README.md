# ULX3S_testing

After cloning repository and submodules run scripts as root:

    # download Debian dependencies
    ./debian-install.sh

    # download micropyton
    ./blob-download.sh

    # create micropython filesystems for esp32 with selftest f32c bit
    ./make-upy-fs.sh

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

# TODO

- [ ] no serial programming by default (needs some option to run `ftx_prog`)
- [ ] force serial number to program for this board


## step 1

FTDI programming

    usb-jtag/linux-amd64/ftx_prog --max-bus-power 500
    usb-jtag/linux-amd64/ftx_prog --manufacturer "FER-RADIONA-EMARD"
    usb-jtag/linux-amd64/ftx_prog --product "ULX3S FPGA 12K v3.0.8"
    usb-jtag/linux-amd64/ftx_prog --new-serial-number 120001
    usb-jtag/linux-amd64/ftx_prog --cbus 2 TxRxLED
    usb-jtag/linux-amd64/ftx_prog --cbus 3 SLEEP
    

RESET USB



## step 2

FLASH passthru based on CHIP_ID

https://github.com/emard/ulx3s-bin/tree/master/fpga/passthru



## step 3

RESET USB



## step 4

ESP32 BURN FUSE ?

https://github.com/emard/ulx3s-bin/blob/master/esp32/burn-efuse-flash-3v3.sh



ESP32 load >> Micropython - files

https://github.com/emard/esp32ecp5

Normal procedure is:

    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin

However, we are installing pre-populated filesystem created using `make-upy-fs.sh`

    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin 0x200000 upy.img


    
ESP32 start selftest from ESP32 filesystem (we can't touch SD card from micropython because
if we do we can't test it)

This files (gzipped) are part of micropython filesystem created by `make-upy-fs.sh`

https://github.com/emard/ulx3s-bin/blob/master/fpga/f32c/f32c-12k-v20/f32c_ulx3s_v20_12k_selftest_100mhz_ws2_flash.img

>>> import ecp5
>>> ecp5.prog("f32c_selftest-25.bit.gz")
I (78530) gpio: GPIO[23]| InputEn: 0| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:0
I (78530) gpio: GPIO[19]| InputEn: 0| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:0
I (78540) gpio: GPIO[18]| InputEn: 0| OutputEn: 0| OpenDrain: 0| Pullup: 1| Pulldown: 0| Intr:0

m32l>


./ulx3s-bin/fpga/f32c/f32cup.py ./ulx3s-bin/fpga/f32c/f32c-bin/selftest-mcp7940n.bin



openFPGALoader --board=ulx3s --device=/dev/ttyUSB0 ulx3s-bin/fpga/f32c/f32c-25k-vector-v20/ulx3s_v20_25f_f32c_selftest_2ws_89mhz.bit
./ulx3s-bin/fpga/f32c/f32cup.py ./ulx3s-bin/fpga/f32c/f32c-bin/selftest-mcp7940n.bin
--> SD ok


Baza upis selftest load Yes

Sve dok svi gumbi barem jednom ne promjene status
I dok vrijeme ne postane različito od default (RTC radi)

10 sekundi >> log file SERIAL

parsanje seriala i ako nađe grešku ne ide dalje

Baza upis selftest pass Yes

power-cycle

## step



ESP32 loada Amigu sa SD kartice

https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.compress.bit

Baza Amiga pass Yes

Upis baza SERIAL test pass

Kada se pokaže disketa

Testiranje gotovo

Ispis veći font SERIAL NO TEST OK

Antistatic bag

Naljepnica serial
