# ULX3S_testing

FTDI programiranje 12F


Baza get new serial

FTDI programiranje seriala

    usb-jtag/linux-amd64/ftx_prog --max-bus-power 500
    usb-jtag/linux-amd64/ftx_prog --manufacturer "FER-RADIONA-EMARD"
    usb-jtag/linux-amd64/ftx_prog --product "ULX3S FPGA 12K v3.0.3"
    usb-jtag/linux-amd64/ftx_prog --new-serial-number 120001
    usb-jtag/linux-amd64/ftx_prog --cbus 2 TxRxLED
    usb-jtag/linux-amd64/ftx_prog --cbus 3 SLEEP
    

RESET USB

FTDI čitanje CHIP ID

fujprog ----

FTDI programiranje CHIP ID

Upisa baza Chip ID


RESET USB

fujprog FLASH passthru CHIP_ID

https://github.com/emard/ulx3s-bin/tree/master/fpga/passthru


RESET USB

ESP32 BURN FUSE ? YES - kako ovo riješiti da ne upisujemo

https://github.com/emard/ulx3s-bin/blob/master/esp32/burn-efuse-flash-3v3.sh


Baza upis FUSE Burned YES


ESP32 load >> Micropython - files

https://github.com/emard/esp32ecp5

    ../ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash
    ../ulx3s-bin/esp32/serial-uploader/esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 460800 write_flash -z 0x1000 esp32-idf3-20191120-v1.11-580-g973f68780.bin
    
Baza upis Micropython Yes


ESP32 loada selftest sa SD kartice

https://github.com/emard/ulx3s-bin/blob/master/fpga/f32c/f32c-12k-v20/f32c_ulx3s_v20_12k_selftest_100mhz_ws2_flash.img


Baza upis selftest load Yes

10 sekundi >> log file SERIAL

parsanje seriala i ako nađe grešku ne ide dalje

Baza upis selftest pass Yes




ESP32 loada Amigu sa SD kartice

https://github.com/kost/ulx3s-minimig/releases/download/v2019.12.25/ulx3s_12f_minimig_ps2kbd.compress.bit

Baza Amiga pass Yes

Upis baza SERIAL test pass

Kada se pokaže disketa

Testiranje gotovo

Ispis veći font SERIAL NO TEST OK

Antistatic bag

Naljepnica serial
