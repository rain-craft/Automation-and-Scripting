#!/bin/bash

p=$(wg genkey) #generating private key


pub=$(echo $p | wg pubkey) #generating public key

address="10.254.132.0/24, 172.16.28.0/24" #sets the addresses

serverAddress="10.254.132.1/24, 172.16.28.1/24"

lport="4282" #sets the listening port

peerInfo="# ${address} 198.199.97.163:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"


echo "${peerInfo}
[Interface]
Address = ${serverAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}"

#check if that output matches the wg0.conf, if it doesn't overwrite it
FILE="/etc/wireguard/wg0.conf"
if test -f "$FILE"; then #the file exists
	echo "This file already exists. Would you live to overwrite it? y/N?"
	read choice
	if(($choice=="y"))
	then #the file needs to be overwritten
		echo "${peerInfo}
[Interface]
Address = ${serverAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}" > /etc/wireguard/wg0.conf
wg addconf wg0 <(wg-quick strip wg0) #restart the VPN
	else #the file doesn't need to be overwritten 
		exit 0
	fi
else #the file doesn't exist
	echo "${peerInfo}
	[Interface]
	Address = ${serverAddress}
	#PostUp = /etc/wireguard/wg-up.bash
	#PostDown = /etc/wireguard/wg-down.bash
	ListenPort = ${lport}
	PrivateKey = ${p}" > /etc/wireguard/wg0.conf
	wg-quick up wg0 #turn on the VPN
	systemctl enable wg-quick@wg0 #enable the VPN to start at startup
fi
echo "all done modify the file"

cat /etc/wireguard/wg0.conf

