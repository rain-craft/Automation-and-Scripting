#!/bin/bash

#checks if the file exists
read -p "Please enter an apache log file " tFile
if [[ ! -f ${tFile} ]]
then
  echo "File doesn't exists."
  exit 1
fi

#extracts all the IP addresses from the log file
while read p; do 
    echo "${p}" | awk '{print $1}' >> IPs.txt
done < "$tFile"

sort IPs.txt > IP2.txt #sort IPs.txt
awk '!x[$0]++' IP2.txt > IPs.txt #remove duplicates IPs.txt

#uses the list of IP addresses to create rulesets for Windows Firewall and iptables
while read p; do 
    echo 'netsh advfirewall firewall add rule name="BLOCK IP ADDRESS -' "${p}"'"'" dir=in action=block remoteip=${p}">>WinFirewall.ps1
    echo "iptables -A INPUT -s ${p} -j DROP" | tee -a badIPs.iptables 
    
done < IPs.txt
