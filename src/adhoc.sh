#!/bin/sh
## Finding Song Home embedded system for Kaffe Matthews
## Copyright (C) 2015 Tom Keene
## 
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

# Very helpful: http://www.teamxlink.co.uk/forum/viewtopic.php?p=233117
DEVICE=$(ip a | grep wlan | awk '{print $2}' | sed s/://g)
SERIAL=$(./grabserial.sh)
ESSID="sonic-$SERIAL"
#iwconfig $DEVICE ap any
#iwconfig $DEVICE txpower 30mW
sudo rfkill unblock wifi
ip link set $DEVICE down
iwconfig $DEVICE mode ad-hoc
iwconfig $DEVICE channel 1
iwconfig $DEVICE essid $ESSID
#iwconfig $DEVICE retry 0
ip link set $DEVICE up 
echo "[adhoc.sh] WiFiStarted \"$ESSID\" ON \"$DEVICE\""
