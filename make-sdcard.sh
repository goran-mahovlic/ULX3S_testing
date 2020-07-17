#!/bin/sh -xe

mkdir /tmp/selftest
cp -v ulx3s-bin/fpga/f32c/*-v20/*selftest*.img /tmp/selftest/
gzip -9 /tmp/selftest/*

