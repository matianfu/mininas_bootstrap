#!/bin/bash

#type=0: create system user
#type=1: change system user's password
#type=2: create system user and samba user
#type=3: change system user's password and samba user's password
type=$1
user_name=$2
new_passwd=$3
old_passwd=$4

current_user=$(whoami)

#create user if not exists
if [ $1 -eq 0 ]
then
	#check user's exists
	egrep "^$user_name" /etc/passwd >& /dev/null  
	if [ $? -ne 0 ]
	then
		if [ current_user="root" ]
		then
    			echo -e "$new_passwd\n$new_passwd\n\n\n\n\n\nY\n" | adduser --no-create-home $user_name
		else
			#the same with root
			echo -e "$new_passwd\n$new_passwd\n\n\n\n\n\nY\n" | adduser --no-create-home $user_name
		fi

		if [ $? -eq 0 ]  
		then  
    			exit 0
		else
			exit 125
		fi
	else
		exit 126
	fi
fi

#change user's password
if [ $1 -eq 1 ]
then
        #check user's exists
        egrep "^$user_name" /etc/passwd >& /dev/null  
        if [ $? -ne 0 ]
        then
		exit 123                  
        fi

	if [ current_user="root" ]
	then
		echo -e "$new_passwd\n$new_passwd\n" | passwd $user_name
	else
		echo -e "$old_passwd\n$new_passwd\n$new_passwd\n" | passwd $user_name
	fi

	if [ $? -eq 0 ]  
	then  
    		exit 0
	else
		exit 124                  
	fi


fi

if [ $1 -eq 2 ]
then
	#check user's exists
	egrep "^$user_name" /etc/passwd >& /dev/null  
	if [ $? -ne 0 ]
	then
		if [ current_user="root" ]
		then
			#create system user
    			echo -e "$new_passwd\n$new_passwd\n\n\n\n\n\nY\n" | adduser --no-create-home $user_name
			#create samba user
			echo -e "$new_passwd\n$new_passwd\n" | smbpasswd -a -s $user_name
		else
			#the same with root
			#create system user
			echo -e "$new_passwd\n$new_passwd\n\n\n\n\n\nY\n" | adduser --no-create-home $user_name
			#create samba user
			echo -e "$new_passwd\n$new_passwd\n$new_passwd\n" | sudo smbpasswd -a -s $user_name
		fi

		if [ $? -eq 0 ]  
		then  
			exit 0
		else
			exit 127
		fi
	else
		exit 128
	fi
fi

if [ $1 -eq 3 ]
then
        #check user's exists
        egrep "^$user_name" /etc/passwd >& /dev/null  
        if [ $? -ne 0 ]
        then
		exit 129                  
        fi

	if [ current_user="root" ]
	then
		#change system user's password
		echo -e "$new_passwd\n$new_passwd\n" | passwd $user_name

		#change samba user's password
		echo -e "$new_passwd\n$new_passwd\n" | smbpasswd -s $user_name
	else
		#change system user's password
		echo -e "$old_passwd\n$new_passwd\n$new_passwd\n" | passwd $user_name

		#change samba user's password
		echo -e "$new_passwd\n$new_passwd\n$new_passwd\n" | sudo smbpasswd -s $user_name
	fi

	if [ $? -eq 0 ]  
	then  
    		exit 0
	else
		exit 130                  
	fi


fi

exit 200

