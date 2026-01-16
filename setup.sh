#!/bin/bash
set -e
# see: https://github.com/fosple/usbmuxd2/blob/master/README.md
service dbus start && service avahi-daemon start
sleep 2

usbmuxd -d -z &
while : ; do
	sleep 10
	ideviceinfo
done
