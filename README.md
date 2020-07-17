# ULX3S_testing


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



## step 5


ESP32 load >> Micropython - files

https://github.com/emard/esp32ecp5

    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin

However, we are installing pre-populated filesystem

    ./ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash --compress 0x1000 blob/esp32/esp32-idf3-20191220-v1.12.bin 0x200000 upy.img
    
Baza upis Micropython Yes


# ESP32 load selftest from SD card

https://github.com/emard/ulx3s-bin/blob/master/fpga/f32c/f32c-12k-v20/f32c_ulx3s_v20_12k_selftest_100mhz_ws2_flash.img

    make-sdcard.sh # helper script to create sdcard

    ls -al ulx3s-bin/fpga/f32c/*-v20/*selftest*.img

import os,machine
os.mount(machine.SDCard(slot=3),"/sd")

import ecp5
ecp5.prog("/sd/f32c_ulx3s_v20_25k_selftest_100mhz_flash.img")

./ulx3s-bin/fpga/f32c/f32cup.py ./ulx3s-bin/fpga/f32c/f32c-bin/selftest-mcp7940n.bin


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
