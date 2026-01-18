#!/bin/bash
set -e

# usage: backup.sh <UUID> <IP>
if [ -z "$1" ]; then
        echo "no device UUID provided!" >&2
        exit 1
fi
DEV_UUID="$1"

if [ -z "$2" ]; then
        echo "no ip address provided!" >&2
        exit 1
fi
IP_ADDRESS="$2"

# see: https://github.com/fosple/usbmuxd2/blob/master/README.md
service dbus start && service avahi-daemon start
sleep 1

PLIST_DIR="/var/lib/lockdown"
plist_files=("$PLIST_DIR/$DEV_UUID.plist" "$PLIST_DIR/SystemConfiguration.plist")

if [ "${#plist_files[@]}" -ne 2 ]; then
  echo "Error: Expected 2 plist files, found ${#plist_files[@]}"
  exit 1
fi

uuid_plist="$(basename "${plist_files[0]}" .plist)"
system_config_plist="${plist_files[1]}"

if [[ "$(basename "$system_config_plist")" != "SystemConfiguration.plist" ]]; then
  echo "Error: Second plist must be SystemConfiguration.plist (did you not supply the correct UUID?)"
  exit 1
fi

echo "UUID plist: $uuid_plist"
echo "SystemConfiguration.plist found: $system_config_plist"

usbmuxd -d -z --allow-heartless-wifi -c $IP_ADDRESS --pair-record-id $uuid_plist &
PID=$!

sleep 2
idevicebackup2 -in backup --full /backup
kill $PID
