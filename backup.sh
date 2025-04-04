#!/bin/bash
if [ -z "$1" ]; then
	echo "no ip address provided!" >&2
	exit 1
fi
IP_ADDRESS="$1"
# see: https://github.com/fosple/usbmuxd2/blob/master/README.md
service dbus start && service avahi-daemon start
sleep 1


PLIST_DIR="/var/lib/lockdown"
plist_files=("$PLIST_DIR"/*.plist)

if [ "${#plist_files[@]}" -ne 2 ]; then
  echo "Error: Expected exactly 2 plist files, found ${#plist_files[@]}"
  exit 1
fi

# Sort to ensure alphabetical order (UUID first, SystemConfiguration second)
IFS=$'\n' sorted_plists=($(sort <<<"${plist_files[*]}"))
unset IFS

uuid_plist="$(basename "${sorted_plists[0]}" .plist)"
system_config_plist="${sorted_plists[1]}"

if [[ "$(basename "$system_config_plist")" != "SystemConfiguration.plist" ]]; then
  echo "Error: Second plist must be SystemConfiguration.plist"
  exit 1
fi

echo "UUID plist: $uuid_plist"
echo "SystemConfiguration.plist found: $system_config_plist"

usbmuxd -c $IP_ADDRESS --pair-record-id $uuid_plist &
PID=$!

sleep 2
idevicebackup2 -in backup --full /backup
kill $PID
# scp * springfield:~/iPhoneBackup/