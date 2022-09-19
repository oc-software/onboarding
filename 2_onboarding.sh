#!/bin/bash

###     Mac onboarding script for phase 2       ###
jamf recon
read -n 1 -srp "Press any key to continue once you are done checking Jamf, or ctrl+c to exit"
jamf policy


echo -e "\nPlease type the new user's username(Do not use quotes):\n"
read username
echo -e "\nPlease type the new user's full name(Do not use quotes):\n"
read fullname

dscl . -create /Users/"$username"
dscl . -create /Users/"$username" RealName "$fullname"
dscl . -create /Users/"$username" UserShell /bin/zsh
dscl . -create /Users/"$username" NFSHomeDirectory /Users/"$username"
dscl . -create /Users/"$username" UniqueID 502
dscl . -create /Users/"$username" PrimaryGroupID 20
echo -e "\nPlease type a temporary password for the new user(Do not use quotes)\n"
read pass
dscl . -passwd /Users/"$username" "$pass"

read -p "Is this user an administrator? [y/n]" continue
echo
if [ "$continue" == "y" ]
then
    dscl . -append /Groups/admin GroupMembership "$username"
    echo -e "\n\n\n!! User added as admin, Please reboot computer !! \n\n\n"
else
    echo -e "\nComplete!\n"
    echo -e "\n\n\n!! Please reboot computer !! \n\n\n"
    exit
fi
