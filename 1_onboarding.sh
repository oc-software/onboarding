#!/bin/bash

###     Mac onboarding script for phase 1       ###

echo -e "\nPlease type the computer name:\n"
read compName
scutil --set HostName "$compName"
scutil --set LocalHostName "$compName"
scutil --set ComputerName "$compName"
echo -e "\nComputer name set to $compName"
dscacheutil -flushcache
echo -e "\nDNS cache flushed. Rebooting in 10 seconds...\n"
sleep 10 ; reboot
