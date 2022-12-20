#!/bin/bash

###     Mac onboarding script for phase 2       ###
jamf recon
read -n 1 -srp "Press any key to continue once you are done checking Jamf, or ctrl+c to exit"
jamf policy

echo -e "\nPleast type the new user's full name:\n"
read -r fullName
echo -e "\nPlease type the new user's username(Do not use quotes):\n"
read -r username
echo -e "\nPlease type a temporary password for the new user(Do not use quotes):\n"
read -r pass
read -r -p "Does this user need a local admin account? [y/n]" isAdmin
echo
if [[ "$isAdmin" == "y" ]]; then
    userPath="/Users/$username"

    dscl . -create "$userPath"
    dscl . -create "$userPath" RealName "$fullName"
    dscl . -create "$userPath" PrimaryGroupID 20
    dscl . -create "$userPath" UserShell /bin/zsh # Can change to /bin/bash if needed
    dscl . -create "$userPath" UniqueID 502
    dscl . -passwd "$userPath" "$pass" # Set password
    dscl . -create "$userPath" NFSHomeDirectory "$userPath"

    echo -e "\nPlease type a temporary password for the user's admin account (Do not use quotes):\n"
    read -r adminPass

    admin="$username.admin"
    adminPath="/Users/$admin"
    userId=$(id -u "$username")
    uniqueId=$((userId + 1))

    dscl . -create "$adminPath"
    dscl . -create "$adminPath" RealName "$fullName(Admin)"
    dscl . -create "$adminPath" PrimaryGroupID 20
    dscl . -create "$adminPath" UserShell /bin/zsh # Can change to /bin/bash if needed
    dscl . -create "$adminPath" UniqueID "$uniqueId"
    dscl . -passwd "$adminPath" "$adminPass" # Set password
    dscl . -create "$adminPath" NFSHomeDirectory "$adminPath"
    dscl . -create "$adminPath" IsHidden 1
    chflags hidden "$adminPath"
    dseditgroup -o edit -t user -a "$adminPath" admin # Add admin user to admin group

    echo -e "\n$username can now be used to log in and $admin can be used to perform administrative functions\n"
    echo -e "\n\n\n!! Please reboot computer !! \n\n\n"
else
    userPath="/Users/$username"
    dscl . -create "$userPath"
    dscl . -create "$userPath" RealName "$fullName"
    dscl . -create "$userPath" PrimaryGroupID 20
    dscl . -create "$userPath" UserShell /bin/zsh # Can change to /bin/bash if needed
    dscl . -create "$userPath" UniqueID 502
    dscl . -passwd "$userPath" "$pass" # Set password
    dscl . -create "$userPath" NFSHomeDirectory /Users/"$username"
    echo -e "\nComplete!\n"
    echo -e "\n\n\n!! Please reboot computer !! \n\n\n"
fi
