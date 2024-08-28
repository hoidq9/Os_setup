#!/bin/bash
all_users=($(cut -d: -f1 /etc/passwd))
all_groups=($(cut -d: -f1 /etc/group))
name_user=""
source variables.sh

user() {
	tput cuu1
	echo -ne "\r\033[KType name user normal: "
	read -r name_user
}

check() {
	for user in "${all_users[@]}"; do
		for group in "${all_groups[@]}"; do
			if [[ $user == $name_user ]] || [[ $group == $name_user ]]; then
				echo -ne "\r\033[KUser already exists"
				sleep 1
				clear_line
				user
				check
			fi
		done
	done
}

clear_line() {
	echo -ne "\r\033[K"
}

create_users() {
	echo -ne "Do you want to create a new user? (y/n): "
	read -r option
	if [[ "$option" == "y" ]]; then
		echo -ne "How many users do you want to create? "
		read -r number
		for ((i = 0; i < number; i++)); do
			echo -e "User $((i + 1))\n"
			user
			check
			sudo adduser "$name_user" &>/dev/null
			sudo passwd "$name_user"
			sudo chsh -s /bin/zsh "$name_user" &>/dev/null
			if [ ! -d "/home/$name_user/Drive" ]; then
				sudo mkdir /home/$name_user/Drive
			fi
			sudo chmod -R 777 /home/$name_user
			cd /home/$name_user/Drive
			git clone https://github.com/hoidq9/rhel_setup.git
			sudo chmod -R 777 /home/$name_user
		done
	elif [[ "$option" == "n" ]]; then
		return
	else
		echo -e "Invalid option"
		exit 1
	fi
}

create_users 2>&1 | tee -a $HOME/Drive/logs/create_users.log
if [[ ${PIPESTATUS[0]} -eq 1 ]]; then
	exit 1
fi
