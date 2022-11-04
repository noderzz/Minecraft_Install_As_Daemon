#!/bin/bash

#Variables
answer=""
javacheck=""

#Check if you have priviledged access
clear
echo "Please ensure you have sudo credentials before starting installation."
echo ""
echo "Does this user have root privileges? (Y/N)"
  read answer

if [ "$answer" != "Y" ] && [ "$answer" != "y" ] && [ "$answer" != "Yes" ] && [ "$answer" != "YES" ] && [ "$answer" != "yes" ]; then 
  echo "So the answer is no."
else
  echo "So the answer is yes."
fi

#Update the Server/Check Java Runtime and Install if missing
javacheck=`java -version 2>&1 | grep version | cut -d '"' -f2 | cut -d "." -f1`
if [ "$javacheck" = 16 ] || [ "$javacheck" = 17 ] || [ "$javacheck" = 18 ]; then 
  echo "Java version is "$javacheck"."
else
  echo "Java version not detected or too old, installing Java now."
  sudo apt install openjdk-18-jre-headless -y
fi

#Create Minecraft User & Install server as that user


#Install mcrcon

#Configure Minecraft Server/RCON

#Create Systemd Unit File/Adjust Firewall

#Configure Backups