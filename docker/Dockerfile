#
# Dockerfile
#
FROM debian:buster-slim
LABEL MAINTAINER="dpavlin@rot13.org"

# files and scripts needed to build the image
# debian-install.sh
RUN apt-get update && apt-get install -y udev libftdi1 libftdi1-2 uhubctl wget libdata-dump-perl libfile-slurp-perl libdevice-serialport-perl python python-serial && apt-get clean

VOLUME ["/ULX3S_testing"]
WORKDIR "/ULX3S_testing"

#CMD ["~/ULX3S_testing/testing.pl"]
# to support testing
CMD ["/bin/bash"]
