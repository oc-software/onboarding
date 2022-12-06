#!/bin/bash

###     Mac onboarding script for phase 2       ###
jamf recon
read -n 1 -srp "Press any key to continue once you are done checking Jamf, or ctrl+c to exit"
jamf policy

echo -e "\nPlease type the new user's username(Do not use quotes):\n"
read -r username

echo -e "\nPlease type a temporary password for the new user(Do not use quotes):\n"
read -r pass

read -r -p "Does this user need a local admin account? [y/n]" continue
echo
if [[ "$continue" == "y" ]]; then
    admin="$username.admin"
    sysadminctl -addUser "$username" -password "$pass"

    echo -e "\nPlease type a temporary password for the user's admin account (Do not use quotes):\n"
    read -r adminPass
    sysadminctl -addUser "$admin" -password "$adminPass" -admin

    echo -e "\n$username can now be used to log in and $admin can be used to perform administrative functions. Make sure the user understands that they should NEVER log in with $admin\n"
    echo -e "\n\n\n!! Please reboot computer !! \n\n\n"
else
    sysadminctl -addUser "$username" -password "$pass"
    echo -e "\nComplete!\n"
    echo -e "\n\n\n!! Please reboot computer !! \n\n\n"
fi
