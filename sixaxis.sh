#!/bin/bash
# Script that is called by udev to launch xboxdrv when a PS3 sixaxis controller is connected. It also 
# terminates the process when the controller disconnects. If you don't want to create any files you could
# just pkill $DEVICE
#
# Place the following in /etc/udev/rules.d/85-input-events.rules
#
# 	ATTRS{name}=="PLAYSTATION*", ENV{DEVNAME}=="/dev/input/event*", RUN+="/path/to/sixaxis.sh $devnode"
#

DEVICE=$1
PID_FILE="/tmp/xboxdrv_pid$(echo $DEVICE | tr '/' '_')"

function startSixaxis () 
{ 
    chmod 600 $DEVICE; #Change original device permissions so Steam does not detect it
    xboxdrv --evdev $DEVICE -d --type xbox360-wireless --silent --evdev-keymap 'KEY_#300=y,KEY_#302=a,KEY_#301=b,BTN_DEAD=x,BTN_TOP=start,BTN_TRIGGER=back,BTN_A=guide,BTN_BASE6=rb,BTN_BASE5=lb,BTN_TOP2=du,BTN_BASE2=dl,BTN_BASE=dd,BTN_PINKIE=dr,BTN_THUMB=tl,BTN_THUMB2=tr' --evdev-absmap 'ABS_#13=rt,ABS_#12=lt,ABS_X=x1,ABS_Y=y1,ABS_Z=x2,ABS_RX=y2' --mimic-xpad-wireless --axismap '-Y1=Y1,-Y2=Y2' --calibration 'RT=0:127:255,LT=0:127:255' &
    PID=$!
    echo "$PID" > $PID_FILE
}

if [[ "$ACTION" == "remove" ]]; then
	PID=$(cat $PID_FILE);
	kill -9 $PID; #SIGKILL required because the process sometimes hangs
	rm $PID_FILE; #Cleanup PID file
fi
if [[ "$ACTION" == "add" ]]; then
	startSixaxis
fi
