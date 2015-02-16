#ifconfig wlan0 down
#iwconfig wlan0 mode ad-hoc
#iwconfig wlan0 essid "x"
#ifconfig wlan0 192.168.1.1 netmask 255.255.255.0 up

#ifconfig wlan0 down
#iwconfig wlan0 mode ad-hoc
#iwconfig wlan0 essid sowifi ap 94:44:52:E7:29:E0 channel 6
#ifconfig wlan0 192.168.2.240
#ifconfig wlan0 up

ifconfig wlan0 down
iwconfig wlan0 channel 4
iwconfig wlan0 mode ad-hoc
iwconfig wlan0 essid 'bikemesh'
#iwconfig wlan0 key password
ifconfig wlan0 192.168.2.1
