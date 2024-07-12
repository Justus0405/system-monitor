#!/bin/bash
clear

VERSION=0.1

## Dashboard Functions

TOP_BAR() {
	echo -e "┌───┤< \e[1;32mSystem Monitor\e[0m >├───┤< \e[1;34mDashboard\e[0m >"
	echo -e "│"
}

USAGE() {
	# This takes to much time to calculate
	#cpu_usage=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')

	# Show ram usage in mb, cut everything except line 2, calculate used percentage
	ram_usage=$(free -m | awk 'NR==2{used=$3; total=$2; avail=$7; printf "%dmb / %dmb (%.0f%%), available: %dmb\n", used, total, used/total*100, avail}')

	# Show total disk usage in gb, only use line total , print values
	disk_usage=$(df -h --total | awk '/total/ {printf "%s / %s (%s), available: %s\n", $3, $2, $5, $4}')

	echo -e "│	┌─[\e[1;35mSystem Usage\e[0m]"
	echo -e "│	├ <\e[1;34mCpu\e[0m>  $cpu_usage%"
	echo -e "│	├ <\e[1;34mRam\e[0m>  $ram_usage"
	echo -e "│	├ <\e[1;34mDisk\e[0m> $disk_usage"
	echo -e "│"
}

TEMPS() {
	# Get Thermal Zones
	thermal_zone0=$(cat /sys/class/thermal/thermal_zone0/type)
	thermal_zone1=$(cat /sys/class/thermal/thermal_zone1/type)
	# Get the current temperatures and divide them by 1000 because they are given back as millicelsius
	thermal_zone0_temp=$(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
	thermal_zone1_temp=$(( $(cat /sys/class/thermal/thermal_zone1/temp) / 1000 ))

	echo -e "│	┌─[\e[1;35mTemperatures\e[0m]"
	echo -e "│	├ <\e[1;34m$thermal_zone0\e[0m> \e[1;36m$thermal_zone0_temp°C\e[0m"
	echo -e "│	├ <\e[1;34m$thermal_zone1\e[0m> \e[1;36m$thermal_zone1_temp°C\e[0m"
	echo -e "│"
}

NETWORK() {
	# Show every IPv4 adress, filter only for the numbers, remove loopback adress, show remaining adress
	local_ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)

	echo -e "│	┌─[\e[1;35mNetwork\e[0m]"
	echo -e "│	├ <Online Status>"
	echo -e "│	├ <\e[1;34mLocal IP\e[0m> $local_ip"
	echo -e "│"
}

OS() {
	KERNEL=$(uname -r)
	UPTIME=$(uptime -p)
	# Reads the age of the file locale.conf to determine the OS age
	AGE=$((($(date +%s) - $(date -r "/etc/locale.conf" +%s)) / 86400))

	echo -e "│	┌─[\e[1;35mOS\e[0m]"
	echo -e "│	├ <\e[1;34mKernel\e[0m> $KERNEL"
	echo -e "│	├ <\e[1;34mUptime\e[0m> $UPTIME"
	echo -e "│	├ <\e[1;34mAge\e[0m>    $AGE days"
	echo -e "│"
}

BOTTOM_BAR() {
	echo -e "└───┤< \e[1;31mVersion $VERSION\e[0m >"
}

TOP_BAR
USAGE
TEMPS
NETWORK
OS
BOTTOM_BAR
