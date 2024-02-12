#!/bin/bash

#checks the access value of the file and ensures it is compliant. If not it suggests how to remedy this
access()
{
#the following values are passed in when the function is called
file=$1 #the file that will be checked
desAcc=$2 #the compliant access value 
remed=$3 #the changes needed to the file permissions if it is not compliant

access=$(stat ${file} | awk 'NR==4 {print $2}'| awk -F/ '{print $1}' | sed 's/(//')

if [[ "${access}" == "${desAcc}"  ]] #if it isn't compliant, suggest how it should be remediated
then
	echo "The permssions of ${file} are not compliant. The current permission is ${access}. It should be ${desAcc}"
	echo "to modify this, run: 
chmod ${remed} ${file}"
else
	echo "The permissions ${file}  are compliant."
fi
}

#checks the uid and gid of the file and ensure they are compliant, if not it suggests how to make them compliant
uid()
{
#the following values are passed in when the function is called
file=$1 #the file being checked
desUID=$2 #the UID needed for compliance
desGID=$3 #the GID needed for compliance
remed=$4 #the compliant group name if ownership needs to be changed 

uid=$(stat $file | awk 'NR==4 {print $5 $6}'|  sed 's/)//')
gid=$(stat $file | awk 'NR==4 {print $9 $10}'|  sed 's/)//')
if [[ "${uid}" != "${desUID}" || "${gid}" != "${desGID}" ]]
then
	echo "The ownership of ${file} is not compliant. It is ${uid}, ${gid} and it should be ${desUID}, ${desGID}."
	echo "To fix this, run the command chown root:${remed} ${file}"
else
	echo "The ownership of ${file} is compliant."
fi 
}

#the above functions are then called on all of the following files

#/etc/crontab
access /etc/crontab 600 og-rwx
uid /etc/crontab 0/root 0/root root

#/etc/cron.hourly
access /etc/cron.hourly 600 og-rwx
uid /etc/cron.hourly 0/root 0/root root

#/etc/cron.daily
access /etc/cron.daily 600 og-rwx
uid /etc/cron.daily 0/root 0/root root

#/etc/cron.weekly
access /etc/cron.weekly 600 og-rwx
uid /etc/cron.weekly 0/root 0/root root

#/etc/cron.monthly
access /etc/cron.monthly 600 og-rwx
uid /etc/cron.monthly 0/root 0/root root

#/etc/passwd
access /etc/passwd 644 644
uid /etc/passwd 0/root 0/root root

#/etc/shadow
access /etc/shadow 640 o-rwx,g-wx
uid /etc/shadow 0/root 42/shadow shadow

#/etc/group
access /etc/group 644 644
uid /etc/group 0/root 0/root root

#/etc/gshadow
access /etc/gshadow 640 o-rwx,g-wx
uid /etc/gshadow 0/root 42/shadow shadow

#/etc/passwd-
access /etc/passwd- 644 u-x,go-wx
uid /etc/passwd- 0/root 0/root root

#/etc/shadow-
access /etc/shadow- 640 o-rwx,g-rw
uid /etc/shadow- 0/root 42/shadow shadow

#/etc/group-
access /etc/group- 644 o-rwx,g-rw
uid /etc/group- 0/root 0/root root

#/etc/gshadow-
access /etc/gshadow- 640 o-rwx,g-rw
uid /etc/gshadow- 0/root 42/shadow shadow

#checks for legacy "+" in files
legacy()
{
file=$1
if (grep '^\+:' ${file})
then 
	echo "${file} is not compliant. There are legacy entries in it."
	echo "To remediate this, remove those entries from ${file}"	
else
	echo "There are no legacy entries in ${file}. It is compliant."
fi
}

#the above function is called on the following file
legacy /etc/passwd
legacy /etc/shadow
legacy /etc/group

#checks if any user other than root has a UID of 0
uidCheck()
{
check=$(cat /etc/passwd | awk -F: '($3 == 0) {print $1}')
if [[ "${check}" != root ]]
then
	echo "A user other than root has a UID of 0."
	echo "To remediate this, remove that user or change their UID"
else
	echo "Only root has a UID of 0"
fi
}
uidCheck

#the following function was written to ensure IP forwarding is disabled on kali Linux. The Ubuntu documentation states the command that should be used is "sysctl net.ipv4.ip forward" however this command does not work on Kali and returns an error that there is no such file or directory. So this function instead checks the /etc/sysctl.conf file and looks for the flag in there
ipForward()
{
forward=$(grep "net\.ipv4\.ip_forward" /etc/sysctl.conf  | awk -F. '{print $3}' | awk -F = '{print $2}')

if [[ ${forward} != 0 ]]
then
	echo "IP forwarding is not compliant. It should have a value of 0 so that it is disabled. But it has a value of ${forward}"
	echo 'To remediate this, go into /etc/sysctl.conf and set the field "net.ipv4.ip_forward = " to 0'
else
	echo "IP forwarding is disabled and compliant."
fi

}
ipForward


icmpRedir()
{
	redir1=$(sysctl net.ipv4.conf.default.accept_redirects | awk '{print $3}')
	redir2=$(grep "net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf  | awk '{print $3}')

	
	if [[ $redir1 != 0 || $redir2 != 0 ]]
	then
		echo "ICMP redirects is not compliant."
		echo "To remediate this:
			Set the following parameters in /etc/sysctl or a /etc/sysctl.d/* file:
				net.ipv4.conf.all.accept_redirects = 0
				net.ipv4.conf.default.accept_redirects = 0
				
			Run the following commands to set the active kernel parameters:
				sysctl -w net.ipv4.conf.all.accept redirects=0
				sysctl -w net.ipv4.conf.default.accept redirects=0
				sysctl -w net.ipv4.route.flush=1"
	
	else
		echo "ICMP redirects are compliant."
	fi
}
icmpRedir
