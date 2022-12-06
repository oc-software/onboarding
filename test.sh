#!/bin/bash

read -n 1 -srp "Press any key to continue or ctrl+c to exit"

echo -e "\nPlease enter a test string\n"
read -r test
echo -e "\n$test\n"
read -r -p "\nDo you like ducks? [y/n]" continue
echo
if [[ "$continue" == "y" ]]; then
  echo -e "\nGood...\n"
else
  echo -e "\nHmmmm....\n"
fi
