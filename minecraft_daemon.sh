#!/bin/bash

#Variables
answer=""

#Check if you are root
clear
echo "Please ensure you have sudo credentials before starting installation."
echo ""
echo "Does this user have root privileges? (Y/N)"
  read answer

if [ "$answer" != "Y" ] && [ "$answer" != "y" ] && [ "$answer" != "Yes" ] && [ "$answer" != "YES" ]&& [ "$answer" != "yes" ]; then 
  echo "So the answer is no."
else
  echo "So the answer is yes."
fi
#Update the Server/Check Java Runtime and Install if missing

#Create Minecraft User & Install server as that user

#Install mcrcon

#Configure Minecraft Server/RCON

#Create Systemd Unit File/Adjust Firewall

#Configure Backups