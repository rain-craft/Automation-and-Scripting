#!/bin/bash

#function to create the badIPs file
badIPs() {
#download the file 
wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules

#pull the IP addresses out of the file and make a list of the IPs to block
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badIPs.txt
}

#check if the badips file exists
FILE="badIPs.txt"
if test -f "$FILE"; then #if yes ask if it should be redownloaded
	read -p "This file already exists. Would you like to overwrite it? y/N" choice

	case "${choice}" in
		Y|y) 
		echo  "Creating badIPs.txt..."
		badIPs
		;;
		N|n) echo "Not redownloading badIPs.txt..."
		;;
		*) 
			echo "Invalid value."
			exit 1
		;;
	esac

else #if it doesnt exist download file
	badIPs
fi

#functions for the various inbound drop rules. these will be called by the switches below

#windows firewall
windows() {
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badips.windowsform
	for eachip in $(cat badips.windowsform)
	do
		echo 'netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachip}\" dir=in action=block remoteip=${eachip}' | tee -a badips.netsh
	done
	rm badips.windowsform
	clear
	echo 'Created IPTables for firewall drop rules in file \"badips.netsh\"'
}

#cisco
cisco() {
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badips.nocidr
for eachIP in $(cat badips.nocidr)
do
	echo "deny ip host ${eachIP} any" | tee -a badips.cisco 
done
rm badips.nocidr
clear
echo 'Created IP Tables for firewall drop rules in file "badips.cisco"'
}

#mac OS
mac() {
echo '
scrub-anchor "com.apple/*"
nat-anchor "com.apple/*"
rdr-anchor "com.apple/*"
dummynet-anchor "com.apple/*"
anchor "com.apple/*"
load anchor "com.apple" from "/etc/pf.anchors/com.apple"

' | tee pf.conf

for eachIP in $(cat badIPs.txt)
do
	echo "block in from ${eachIP} to any" | tee -a pf.conf 
done
clear
echo 'Created IP tables for firewall drop rules in file \"pf.conf\"'
}

#iptables
iptables() {
for eachIP in $(cat badIPs.txt)
do
	echo "iptables -A INPUT -s $(eachIP) -j DROP" | tee -a badIPs.iptables #iptable
done
clear
	echo 'Created IPTables firewall drop rules in file \"badips.iptables\"'
}

#parse the cisco file
parse() {
wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	awk '/domain/ {print}' /tmp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	for eachip in $(cat threats.txt)
	do
		echo 'match protocol http host \"${eachip}\"' | tee -a ciscothreats.txt
	done
	rm threats.txt
	echo 'Cisco URL filters file successfully parsed and created at "ciscothreats.txt"'
}

#switches for the various inbound drop rules
while getopts 'cdmfi' OPTION ; do
	case "${OPTION}" in
		c) cisco
		;;
		d) parse
		;;
		m) mac
		;;
		f) windows
		;;
		i) iptables
		;;
		*)
			echo "Invalid Value"
			exit 1
		;;
	esac
done





