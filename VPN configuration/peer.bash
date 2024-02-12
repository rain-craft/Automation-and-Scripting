#!/bin/bash
#peer VPN configuration file
p=$(wg genkey) #generating private key
clientPub=$(echo $p | wg pubkey) #generating public key
pre="$(wg genpsk)"
end="$(head -1 /etc/wireguard/wg0.conf | awk '{print $4}')" #endpoit
pub="$(head -1 /etc/wireguard/wg0.conf | awk '{print $5}')" #server's public key
dns="$(head -1 /etc/wireguard/wg0.conf | awk '{print $6}')" #dns server

mtu="$(head -1 /etc/wireguard/wg0.conf | awk '{print $7}')" #MTU
keep="$(head -1 /etc/wireguard/wg0.conf | awk '{print $8}')" #keep alive
lport="$(shuf -n 1 -i 40000-50000)" #lisenPort
routes="$(head -1 /etc/wireguard/wg0.conf | awk '{print $9}')"



echo -n "What is the client's name? " #get clients name
read clientN

pFILE="/etc/wireguard/${clientN}-wg0.conf" #peer file variable

if test -f "$FILE"; then #check if peer file exists
	echo "The file ${clientN} already exists"
	echo -n "Do you want to overwrite it? y/N"
	read overW
	
	if (($overW=="y")) #they want to overwrite it
	then
		echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}

[Peer]
AllowedIps = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFILE} # write the peer file
	echo "# rain begin
	[Peer]
	Publickey= ${clientPub}
	PreSharedKey = ${pre}
	AllowedIps = 10.0.254.132.100/32
	# rain end" >> /etc/wireguard/wg0.conf #adding to the server config
	else #they don't want to overwrite
		exit 0 #exitting program
	fi
else
	echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}

[Peer]
AllowedIps = ${routes}
PersistentKeepalive = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFILE} #write the peer file

echo "# rain begin
[Peer]
Publickey= ${clientPub}
PreSharedKey = ${pre}
AllowedIps = 10.0.254.132.100/32
# rain end" >> /etc/wireguard/wg0.conf #adding to the server config
fi
