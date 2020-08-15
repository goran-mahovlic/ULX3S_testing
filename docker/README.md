# Docker images

First, you still need to create sdcard image for saxonsoc using:

    ./make-sdcard.sh /dev/mmcblk0


In `docker` directory is `Makefile` with following targets:

    root@x230:/home/dpavlin/ULX3S_testing/docker# make testing

This is also default target which will enable you to re-program FPGA
wihthout changing FTDI settings and serial number (this is useful for
testing before production run).

Once you want to run production, clean all files in `data` directory,
optionally create directory with serial number which is one less than
first board and run `production` target:

    root@x230:/home/dpavlin/ULX3S_testing/docker# make production

This will execute script with `PRODUCTION=1` enviroment variable to
do full programming of blank ULX3S boards.


There is one more target which is useful for debugging:

    root@x230:/home/dpavlin/ULX3S_testing/docker# make bash

This will open `bash` prompt on which you can execute commands inside
docker container.

