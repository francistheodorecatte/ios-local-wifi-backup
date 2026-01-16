# see: https://github.com/libimobiledevice/libusbmuxd/issues/88#issuecomment-2399988011
FROM debian:11-slim

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential pkg-config checkinstall git autoconf automake
RUN apt-get install -y libtool-bin libssl-dev libcurl4-openssl-dev
RUN apt-get install -y libavahi-client-dev avahi-daemon avahi-utils

ENV INSTALL_PATH /src
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

RUN git clone https://github.com/libusb/libusb.git \
  && cd /src/libusb \
  && ./bootstrap.sh \
  && ./configure --enable-udev=no \
  && make \
  && make install

RUN git clone https://github.com/libimobiledevice/libplist.git \
  && cd /src/libplist \
  && ./autogen.sh \
  && make \
  && make install

RUN git clone https://github.com/libimobiledevice/libimobiledevice-glue.git \
  && cd /src/libimobiledevice-glue \
  && ./autogen.sh \
  && make \
  && make install

RUN git clone https://github.com/libimobiledevice/libtatsu.git \
  && cd /src/libtatsu \
  && ./autogen.sh \
  && make \
  && make install

RUN git clone https://github.com/libimobiledevice/libusbmuxd.git \
  && cd /src/libusbmuxd \
  && ./autogen.sh \
  && make \
  && make install

RUN git clone https://github.com/libimobiledevice/libimobiledevice.git \
  && cd /src/libimobiledevice \
  && ./autogen.sh \
  && make \
  && make install

RUN git clone https://github.com/tihmstar/libgeneral.git \
  && cd /src/libgeneral \
  && ./autogen.sh \
  && make \
  && make install

RUN git clone https://github.com/fosple/usbmuxd2.git \
  && cd /src/usbmuxd2 \
  && apt-get install -y clang \
  && ./autogen.sh \
  && ./configure CC=clang CXX=clang++ \
  && make \
  && make install

RUN rm -r ./*

WORKDIR /root
COPY backup.sh .
COPY setup.sh .
RUN chmod +x *.sh
