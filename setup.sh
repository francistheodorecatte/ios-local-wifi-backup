#!/bin/bash
set -e

# see: https://github.com/fosple/usbmuxd2/blob/master/README.md
service dbus start && service avahi-daemon start
sleep 2

usbmuxd -d -z &

sleep 10
ideviceinfo

UUID=$(idevice_id -l)
if [ -f "/var/lib/lockdown/$UUID.plist" ]; then
        echo -e "\nNewly paired device ID is: $UUID"
        exit 0
else
        echo -e "\nusbmuxd failed to create device plist (did pairing fail?)"
        exit 1
fi
