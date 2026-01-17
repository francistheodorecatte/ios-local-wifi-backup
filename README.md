iOS devices can actually backup a full system image locally over wifi and don't need to rely on iCloud at all

however, you can't normally backup over wifi to a server or have an iPhone/iPad initiate the backup, you have to manually click "back up now" on your mac in the user interface. as far as i know, there's no way to automate this on macos.

iCloud gives you scheduled backups or backups on demand from your phone, i'd like that functionality but with local storage

to that end, this repo contains simple instructions, a dockerfile and scripts to help big dummies like me get wifi backup working on iphone via local WiFi and VPNs to a linux server

note: this doesn't seem to work on a macos host, you need a linux host machine. drop the example 60-ios.rules file in /etc/udev/rules.d/ on your host machine, and run `udevadm control --reload rules` prior to running these scripts. on most distros it's the default, but make sure your user is in the `plugdev` group!

this is based on libimobiledevice and fosple's fork of usbmuxd2.

to build the Docker container for the first time, clone the repo then do:

```sh
mkdir -p ~/.local/lockdown
podman build -t ios-local-backup -f ./Dockerfile
```

note that this should work with docker (podman is a completely open-source, direct drop-in for it), if you prefer that over systemd-podman, and currently only supports one device at a time. there will likely be a script rewrite to support specifying a device uuid to support multiple iOS devices.

`--network=host --privileged` and the udev rules are required here so that USB and networking works properly.

for first-time setup, make sure wifi sync is enabled via a mac/windows machine in the iPhone/iPad's settings (via iTunes), then plug iphone in via usb, run `setup.sh` in the docker container and pair the iphone. this creates the two required plist files in `lockdown`. e.g.:

```sh
podman run -it --rm --privileged --v /mnt/ios-backups:/backup -v /home/<user>/.local/lockdown:/var/lib/lockdown --network=host localhost/ios-local-backup setup.sh
```

with the iPhone/iPad unplugged from your host machine, run `backup.sh <iphone ip>` in the container to backup remotely. you can run this as one command from the host:

```sh
podman run -it --rm --privileged --v /mnt/ios-backups:/backup -v /home/<user>/.local/lockdown:/var/lib/lockdown --network=host localhost/ios-local-backup backup.sh <ip>
```

you can setup a 'Shortcut' on iOS that grabs the phones local ip address and passes it to an ssh command to avoid setting a static ip on your iPhone/iPad.
