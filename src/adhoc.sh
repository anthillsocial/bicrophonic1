# Lets kill old wifi processes
N=$(ps aux | grep dhclient | grep -v grep)
if [ ! -z "$N" ]; then
    ps aux | grep dhclient | awk '{ print $2}' | xargs kill -9
fi
# Create an adhoc network named "sonic{BBBserial}"
createAdHocNetwork(){
    SERIAL=$(print_serial)
    ESSID="sonic-$SERIAL"
    DEVICE="wlan0"
    ifconfig wlan0 down
    iwconfig wlan0 mode Ad-Hoc key off
    iwconfig wlan0 channel 4
    #iwconfig wlan0 key aaaaa11111 #WEP key you can change this but keep it 10 digits
    iwconfig wlan0 essid $ESSID   #SSID set this to whatever you want
    ifconfig wlan0 10.0.0.200 netmask 255.255.255.0 up
    #/usr/sbin/dhcpd wlan0
    #dhclient $DEVICE 
    echo "Created Adhoc "$ESSID" at 10.0.0.200"
}
#ifconfig wlan0 down
#iwconfig wlan0 mode ad-hoc
#iwconfig wlan0 essid "x"
#ifconfig wlan0 192.168.1.1 netmask 255.255.255.0 up

#ifconfig wlan0 down
#iwconfig wlan0 mode ad-hoc
#iwconfig wlan0 essid $ESSID ap 94:44:52:E7:29:E0 channel 6
#ifconfig wlan0 192.168.2.240
#ifconfig wlan0 up

#ip link set $DEVICE down
#ifconfig $DEVICE down
#iwconfig $DEVICE channel 4
#iwconfig $DEVICE mode ad-hoc
#iwconfig $DEVICE essid $ESSID
#iwconfig wlan0 key password
#ifconfig $DEVICE 192.168.2.1
#ifconfig $DEVICE up

# Grab the unique serial number of the BBB
notif () {
    echo "${1}${2}"
}
fail () {
    echo "${1}${2}"
    exit 0
}
checks () {
    if ! [ $(id -u) = 0 ]; then
    fail "you need to be root to run this (or use sudo)."
fi
has_hexdump=$(which hexdump 2>/dev/null)
    if [ ! "${has_hexdump}" ]; then
    fail "you need to install the BSD utils (apt-get install bsdmainutils)."
fi
}
print_serial () {
    EEPROM="/sys/bus/i2c/devices/1-0050/eeprom"
    if [ ! -f "${EEPROM}" ]; then
        EEPROM="/sys/bus/i2c/devices/0-0050/eeprom"
    fi
    if [ ! -f "${EEPROM}" ]; then
        fail "i2c eeprom file not found in sysfs."
    fi
    SERIAL=$(hexdump -e '8/1 "%c"' "${EEPROM}" -s 16 -n 12 2>&1)
    if [ "${SERIAL}" = "${SERIAL#*BB}" ]; then
        fail "failed to extract serial number from i2c eeprom: " "${SERIAL}"
    fi
    notif "${SERIAL}"
}
createAdHocNetwork

