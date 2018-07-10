#!/bin/bash

function restartNetwork() {
	echo 'Restarting Network'
	sudo netctl stop harrhy
	sudo netctl start harrhy
}
function pingAddress() {
	printf '  %q\n' "$1"
	ping -c 6 $2
}
function checkNetwork() {
	echo 'Checking Network'
	pingAddress "Wifi-Router:" 192.168.1.1
	pingAddress "Second-Router:" 192.168.2.1
	pingAddress "Google-DNS:" 8.8.8.8
	pingAddress "google.com:" google.com
}

function startAudio() {
	pkill pulseaudio
	pulseaudio --start
}

function restartDisplay() {
	echo 'Restarting Display'
	xrandr --output HDMI1 --off --output LVDS1 --mode 720x405 --pos 0x675 --rotate normal --output VIRTUAL1 --off --output DP1 --off --output VGA1 --primary --mode 1920x1080 --pos 720x0 --rotate normal
}

function initRedshift() {
	echo 'Initiating redshift process in another thread...'
	pkill redshift
	redshift -l 47.565520:-52.765419 > /dev/null &
}

if [ $1 ]; then
	case $1 in
		startup)
			startAudio
			restartNetwork
			restartDisplay
			initRedshift
			;;

		restart-network)
			restartNetwork
			;;

		check-network)
			checkNetwork
			;;

		restart-display)
			restartDisplay
			;;

		heal-eyes)
			initRedshift
			;;

		*)
			echo 'Unknown Command'
	esac
fi
