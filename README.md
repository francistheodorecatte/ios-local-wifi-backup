### Introduction
iOS devices can actually backup a full system image locally over wifi, and don't need to rely on iCloud at all! Wireless syncing was actually introduced at the same time as iCloud was, with the 2011 release of iOS 5.

however, you can't schedule backups over wifi to a server, or have an iPhone/iPad initiate the backup—you have to manually click "back up now" on your mac in the user interface, with no way to automate this process. only iCloud gives you scheduled backups or backups on demand from your phone, but that functionality should be possible with local storage!

to that end, this repo contains simple instructions, a dockerfile and scripts to get networked backups working on iOS devices via local Wi-Fi and VPNs to a linux server.

note: this doesn't seem to work on a macos host, you need a linux host machine.

this is based on libimobiledevice and fosple's fork of usbmuxd2, and inspired mostly by this github issue comment:
https://github.com/libimobiledevice/libusbmuxd/issues/88#issuecomment-2399988011

### Usage
drop the example 60-ios.rules file in /etc/udev/rules.d/ on your host machine, and run `udevadm control --reload rules` first. on most distros it's the default, but make sure your user is in the `plugdev` group!

to build the Docker container for the first time, clone the repo then do:

```sh
mkdir -p ~/.local/lockdown
podman build -t ios-local-backup -f ./Dockerfile
```

note that this should work with docker like the original, unforked version (podman is a completely open-source, direct drop-in for it), if you prefer that over systemd-podman.

`--network=host --privileged` and the udev rules are required here so that USB and networking works properly. without the udev rules you will likely run into libusb permissions errors!

for first-time setup, make sure wifi sync is enabled via a mac/windows machine in the iPhone/iPad's settings (e.g. the `Sync with this device over Wi-Fi` checkbox in iTunes), then plug iphone in via usb, run `setup.sh` in the docker container and pair the iphone. **note the UUID printed at the end of the script**; this is the UUID of your device which will be needed in the next step:

```sh
podman run -it --rm --privileged --network=host -v /mnt/ios-backups:/backup -v /home/<user>/.local/lockdown:/var/lib/lockdown localhost/ios-local-backup setup.sh
```

with the iPhone/iPad unplugged from your host machine, run `backup.sh <UUID> <ip>` in the container to backup remotely. you can run this as one command from the host:

```sh
podman run -it --rm --privileged --network=host -v /mnt/ios-backups:/backup -v /home/<user>/.local/lockdown:/var/lib/lockdown localhost/ios-local-backup backup.sh <UUID> <ip>
```

if your device is not setup for wireless syncing, the script will spit out `ERROR: Could not connect to lockdownd, error code -8`! otherwise, you will be prompted to enter your PIN on the device being backed up, and the backup will start. note that this process is pretty slow for the initial backup; all subsequent ones are incremental and should go significantly faster.

you can setup a 'Shortcut' on iOS that grabs the phones local ip address and passes it to an ssh command to avoid setting a static ip on your iPhone/iPad, and running the backup command manually.
