Bicrophonic1
============

Platform to play audio attached geographical locations and the movements of a bike http://sonicbikes.net
NOTE: Currently in active development, not yet working

Roadmap
-----------------
- Create eject button/led for the SD card...
- Pre-load sounds.
- Manage audio memory.
- Check log folder exists

Map control
-----------------
A JSON file controls how and where sounds are played. The paramterers are:

- Sound filename (the title of the zone)
- Direction parameter: (Multiple select for NE etc.) 
  - North (Sample is played when moving north) 
  - South (Sample is played when moving south) 
  - East (Sample is played when moving east)
  - West (Sample is played when moving west)
- Pan Paramter: 
  - North (If cycling north and you want sound out of Left speaker set to west)
  - South (If cycling south and you want sound out of Left speaker set to east)
  - East (If cycling east and you want sound out of Left speaker set to north)
  - West (If cycling west and you want sound out of Left speaker set to south)
- Sample parameters: 
  - Loop (Sound file will loop on entering a zone and stop on leaving)
  - Ghost (two polygons are drawn and the zone oscillates between them)
  - One shot (Sample will play to the end whatever happens)

Outline of The software
=============

# 'worms'
The 'worms' script has been written with python and currently: 

- Scans for wifi signals and sends OSC messages based on what it finds.
- Reads analog input and sends OSC messages based on what it finds.

## Install
First we need to install adafruit's beaglebone-io-python libarary. This provides fast access to the BBB's analog pins.

    $ git clone THIS REPOSITORY
    $ ntpdate -b -s -u pool.ntp.org
    $ git clone git://github.com/adafruit/adafruit-beaglebone-io-python.git
    $ cd adafruit-beaglebone-io-python/
    $ sudo python ./setup.py install    
    $ sudo apt-get install python-psutil

## Wiring

    Pin34<-->10kesitor<-->switch<-->Pin32
                        |            
                        --->Pin40   

## Then the script can be test on its own

    $ sudo ./worms
                     
WHOLE BBB Setup
==================

The SD Card
-----------
We need an SD card that can be read by Linux and OSX. To set this up:

- Format the SD card as fat32 (I used gparted on Linux).
- Lable the sdcard "biophonic1"
- Copy some audio files onto the SD card.
- Plug the SD crad into the BBB and mount the filesystem (work out /dev/mmcblk1p1 using "lsblk"):

    $ mkdir ~/sdcard
    $ sudo mount -L biophonic1 -t vfat sdcard -o umask=000

And there you go...

Notes
=====================
http://www.adminempire.com/how-to-install-arch-linux-on-beaglebone-black-bbb





