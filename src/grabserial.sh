# Make sure this script is runs as root so network/mount things work
LUID=$(id -u)
if [ $LUID -ne 0 ]; then
    echo "$0 must be run as root"
    exit 1
fi
# Grab the unique serial number of the BBB
grabserial(){
    print_serial
}
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
grabserial

