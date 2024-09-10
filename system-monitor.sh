#!/bin/bash
clear

VERSION=0.2

## Dashboard Functions

TOP_BAR() {
	echo -e "┌───┤< \e[1;32mSystem Monitor\e[0m >"
	echo -e "│"
}

USAGE() {
	# Try calculate current CPU usage
	cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=100-($5*100)/($2+$3+$4+$5+$6+$7+$8)} END {printf "%.0f", usage}')

	# Show ram usage in mb, cut everything except line 2, calculate used percentage
	ram_usage=$(free -m | awk 'NR==2{used=$3; total=$2; avail=$7; printf "%dmb / %dmb (%.0f%%), available: %dmb\n", used, total, used/total*100, avail}')

	# Show total disk usage in gb, only use line total , print values
	disk_usage=$(df -h --total | awk '/total/ {printf "%s / %s (%s), available: %s\n", $3, $2, $5, $4}')

	echo -e "│	┌─[\e[1;35mSystem Usage\e[0m]"
	echo -e "│	├ <\e[1;34mCpu\e[0m>      $cpu_usage%"
	echo -e "│	├ <\e[1;34mRam\e[0m>      $ram_usage"
	echo -e "│	├ <\e[1;34mDisk\e[0m>     $disk_usage"
	echo -e "│"
}

NETWORK() {
	# Tries to ping google dns server, if successful return Online, if not return Offline
	online_status=$(if ping -c 1 8.8.8.8 &> /dev/null; then echo -e "\e[1;32mOnline\e[0m"; else echo -e "\e[1;31mOffline\e[0m"; fi)

	# Show every IPv4 adress, filter only for the numbers, remove loopback adress, show remaining adress
	local_ip=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)

	echo -e "│	┌─[\e[1;35mNetwork\e[0m]"
	echo -e "│	├ <\e[1;34mInternet\e[0m> $online_status"
	echo -e "│	├ <\e[1;34mLocal IP\e[0m> $local_ip"
	echo -e "│"
}

OS() {
	KERNEL=$(uname -r)
	UPTIME=$(uptime -p)
	# Reads the age of the file machine-id to determine the OS age
	if [[ -f "/etc/machine-id" ]]; then
		AGE=$((($(date +%s) - $(date -r "/etc/machine-id" +%s)) / 86400))
	else
		AGE="Error: File not found"
	fi

	echo -e "│	┌─[\e[1;35mOS\e[0m]"
	echo -e "│	├ <\e[1;34mKernel\e[0m>   $KERNEL"
	echo -e "│	├ <\e[1;34mUptime\e[0m>   $UPTIME"
	echo -e "│	├ <\e[1;34mAge\e[0m>      $AGE days"
	echo -e "│"
}

# Function to find temperature file paths
FIND_TEMP_PATH() {
	local potential_paths=("$@")
		for path in "${potential_paths[@]}"; do
			if [ -f "$path" ] && [ -s "$path" ]; then
				echo "$path"
				return 0
			fi
		done
	echo ""
}

TEMPS() {
	echo -e "│	┌─[\e[1;35mTemperatures\e[0m]"

	potential_paths_zone0=(
		"/sys/class/thermal/thermal_zone0/temp"
		"/sys/class/hwmon/hwmon0/temp1_input"
		"/sys/class/hwmon/hwmon1/temp1_input"
	)
	potential_paths_zone1=(
		"/sys/class/thermal/thermal_zone1/temp"
		"/sys/class/hwmon/hwmon0/temp2_input"
		"/sys/class/hwmon/hwmon1/temp2_input"
	)

	thermal_zone0_path=$(FIND_TEMP_PATH "${potential_paths_zone0[@]}")
	thermal_zone1_path=$(FIND_TEMP_PATH "${potential_paths_zone1[@]}")

	if [ -n "$thermal_zone0_path" ]; then
		temp0=$(cat "$thermal_zone0_path" 2>/dev/null)
		if [[ $temp0 =~ ^[0-9]+$ ]]; then
			thermal_zone0=$(cat /sys/class/thermal/thermal_zone0/type 2>/dev/null || echo "Zone 0")
			thermal_zone0_temp=$((temp0 / 1000))
			echo -e "│	├ <\e[1;34m$thermal_zone0\e[0m> \e[1;36m${thermal_zone0_temp}°C\e[0m"
		fi
	fi

	if [ -n "$thermal_zone1_path" ]; then
		temp1=$(cat "$thermal_zone1_path" 2>/dev/null)
		if [[ $temp1 =~ ^[0-9]+$ ]]; then
			thermal_zone1=$(cat /sys/class/thermal/thermal_zone1/type 2>/dev/null || echo "Zone 1")
			thermal_zone1_temp=$((temp1 / 1000))
			echo -e "│	├ <\e[1;34m$thermal_zone1\e[0m> \e[1;36m${thermal_zone1_temp}°C\e[0m"
		fi
	fi

	# If no temperature sensors where found
	if [ -z "$thermal_zone0_path" ] && [ -z "$thermal_zone1_path" ]; then
		echo -e "│	├ <\e[1;31mNo temperature data available\e[0m>"
	fi

	echo -e "│"
}
BOTTOM_BAR() {
	echo -e "└───┤< \e[1;31mVersion $VERSION\e[0m >"
}

TOP_BAR
USAGE
NETWORK
OS
TEMPS
BOTTOM_BAR
