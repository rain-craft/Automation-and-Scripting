#!/bin/bash

#Menu for admin, VPN, and security functions
function invalidO() {
	echo "Please enter a valid option"
	sleep 2
}

function menu() {
	clear #clears the screen
	echo "
	[1] Admin Menu
	[2] Security Menu
	[3] Exit"
	read -p "Please enter your choice: " choice
	case "${choice}" in
    	1)adminM
    	;;
    	2)secMenu
    	;;
    	3)exit 0
    	;;
    	*)
        	invalidO
    	;;
	esac
	menu #calls back to main menu
}

function adminM() {
	clear
	echo "
	[P]rocesses
	[N]etwork Sockets
	[V]PN Menu
	[A]dd a user
	[E]xit
	[M]ain Menu"
	read -p "Please enter your choice: " choice
    
	case "${choice}" in
    	P|p) ps -ef | less
    	;;
    	N|n) netstat -an --inet | less
    	;;
    	V|v) vpnM
    	;;
    	E|e) exit 0
    	;;
    	A|a) 
    	echo "what is the name of the user you wish to add?"
    	read uname
    	sudo useradd $uname
    	cat /etc/passwd | grep $uname
    	sleep 2
    	;;
    	M|m)
    	menu
    	;;
    	*)
        	invalidO
    	;;
	esac
	adminM #calls the admin menu
}



function secMenu {
	clear
	echo "
	[O]pen Network sockets
	[U]sers with a UID of 0
	[L]ast 10 logged in users
	[C]urrently logged in users
	[E]xit"
	read -p "Please enter your choice: " choice
	
	case "${choice}" in
    	O|o) lsof -nP | less
    	;;
    	U|u) 
    	grep ":0:" /etc/passwd
    	sleep 2
    	;;
    	E|e) exit 0
    	;;
    	L|l) 
    	last -n 10
    	sleep 2
    	;;
    	C|c) 
    	w
    	sleep 2
    	;;
    	*)
        	invalidO
    	;;
	esac
    
	
	secMenu #calls the admin menu
}




function vpnM(){
	clear
	echo "[A]dd a peer"
	echo "[D]elete a peer"
	echo "[B]ack to admin Menu"
	echo "[M]ain Menu"
	echo "[E]xit"
	read -p "Please slect an option: " choice
    
	case "${choice}" in
    	A|a)
    	read -p "What is the name of the peer you'd like to add?" name
    	bash peers.bash $name
    	tail -6 /etc/wireguard/wg0.conf | less
    	;;
    	D|d)
    	read -p "What is the name of the peer you'd like to delete?" name
    	bash manage-users.bash -d -u $name
    	tail -6 /etc/wireguard/wg0.conf | less
    	;;
    	B|b) adminM
    	;;
    	M|m) menu
    	;;
    	E|e) exit 0
    	;;
    	S|s) testy
    	;;
    	*)
    	invalidO
    	;;
	esac
	vpnM
}


menu #calls the main function
