DEVICE=$(ip a | grep wlan | awk '{print $2}' | sed s/://g)
ESSID="sonic-pop"
#iwconfig $DEVICE ap any
#iwconfig $DEVICE txpower 30mW
#http://www.teamxlink.co.uk/forum/viewtopic.php?p=233117
sudo rfkill unblock wifi
ip link set $DEVICE down
iwconfig $DEVICE mode ad-hoc
iwconfig $DEVICE channel 1
iwconfig $DEVICE essid $ESSID
#iwconfig $DEVICE retry 0
ip link set $DEVICE up 
echo "WiFiStarted \"$ESSID\" ON \"$DEVICE\""
