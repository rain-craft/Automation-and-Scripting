#!/bin/bash


while getopts 'hdau:' OPTION ; do
    case "${OPTION}" in
    	d) u_del=${OPTION}
    	;;
    	a) u_add=${OPTION}
    	;;
    	u) t_user=${OPTARG}
    	;;
    	h)
        	echo ""
        	echo "Usage: $(basename $0) [-all]|[-d] -u username"
        	echo ""
        	exit 1
    	;;
    	*)
        	echo "Invalid value"
        	exit 1
    	;;
   	 

    esac
done

if [[ ${u_del} == "" && ${u_add} == "" ]] || [[ ${u_add} != "" && ${u_del} != "" ]]
then
	echo "PLease sepcify -a or -d and the -u and username"
	exit 1
fi

if [[ $u_add != "" || $u_del != "" ]] && [[ $t_user == "" ]]
then
	echo "Please specify a user"
    
fi

if [[ $u_del ]]
then
	echo "Deleting user..."
	echo "${t_user}"
	sed -i "/# ${t_user} begin/,/# ${t_user} end/d" /etc/wireguard/wg0.conf
fi

if [[ $u_add ]]
then
	echo "Create the User..."
	sudo bash peers.bash ${t_user}
fi
