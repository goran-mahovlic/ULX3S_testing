#!/bin/sh -xe

apt-get install -y libftdi1-2 libftdi1-dev libudev-dev cmake pkg-config g++ git

test -d openFPGALoader || git clone https://github.com/trabucayre/openFPGALoader

cd openFPGALoader/
test -d build && rm -Rfv build
mkdir build
cd build
cmake ..
make
cp -v openFPGALoader ../../blob/

cd ../..

test -d fujprog || git clone https://github.com/kost/fujprog

cd fujprog
test -d build && rm -Rfv build
mkdir build
cd build
cmake ..
make
cp -v fujprog ../../blob/

cd ../..

apt-get install -y libftdi-dev

test -d ftx-prog || git clone https://github.com/richardeoin/ftx-prog

cd ftx-prog
make
cp -v ftx_prog ../blob/
