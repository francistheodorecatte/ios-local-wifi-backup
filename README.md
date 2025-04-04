iOS devices can actually backup a full system image locally over wifi and don't need to rely on iCloud at all

however, you can't normally backup over wifi to a server or have the iPhone initiate the backup, you have to manually click "back up now" on your mac in the user interface. as far as i know, there's no way to automate this on macos.

iCloud gives you scheduled backups or backups on demand from your phone, i'd like that functionality but with local storage

to that end, this repo contains simple instructions, a dockerfile and scripts to help big dummies like me get wifi backup working on iphone via local WiFi and VPNs to a linux server

note: this doesn't seem to work on a macos host, you need a linux host machine

this is based on libimobiledevice and fosple's fork of usbmuxd2. a docker image is provided in this repo

to build and start the container for the first time, clone the repo then do:

```sh
docker build -t localhost/libimobiledevice .
$ docker run -it -v ./backup:/backup -v ./lockdown:/var/lib/lockdown --rm --network=host --privileged localhost/libimobiledevice bash
```

`--network=host --privileged` are required here so that USB and networking works properly

to setup, first make sure wifi sync is enabled via a mac/windows machine in the iphone's settings

then plug iphone in via usb, run `/src/setup.sh` in the docker container and pair the iphone, this creates the required plist files in `lockdown`

you should verify they're there afterwards, you should have two files, a uuid.plist and a SystemConfiguration.plist file in the lockdown folder

without iphone plugged in via usb anymore, run `/src/backup.sh <iphone ip>` in the container to backup remotely, you can run this as one command from the host:

```sh
docker run -v ./backup:/backup -v ./lockdown:/var/lib/lockdown --rm --network=host --privileged localhost/libimobiledevice /src/backup.sh <ip>
```

you can setup a 'Shortcut' on iOS that grabs the phones local ip address and passes it to an ssh command to avoid setting a static ip on your iPhone
