#!/bin/bash

#variables
CYN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'
GRN='\033[0;32m'
is_mc_server_running=""
is_mc_server_private=""
user_response=""
mc_username=""
rcon_port=`sudo cat /opt/minecraft/server/server.properties | grep rcon.port | cut -d= -f2`
rcon_password=`sudo cat /opt/minecraft/server/server.properties | grep rcon.password | cut -d= -f2`

#Verify Minecraft Server is running
is_mc_server_running=`sudo systemctl status minecraft | grep Active | cut -d: -f2 | cut -d" " -f2`
if [ "$is_mc_server_running" != "active" ]; then
    echo "Unfortunately it looks like the Minecraft server is not running."
    echo "Please start the minecraft server and then try running the script again" && echo ""
    echo 'You may want to try running "sudo systemctl restart minecraft".'
    exit
fi

#Check to see if the server is already enforcing the whitelist
clear
is_mc_server_private=`sudo cat /opt/minecraft/server/server.properties | grep enforce-whitelist | cut -d= -f2`
if [ "$is_mc_server_private" != "true" ]; then
    echo "This script will make your server into a private server and require you to whitelist everyone who wants to play.  Do you want to proceed?"
    echo "
    1) Yes
    2) No

    "
        while true; do
          read -r -p 'Please select option "1" or "2": ' user_response
          case "$user_response" in
            1)
                sudo sed -i "s/\("enforce-whitelist" *= *\).*/\1true/" /opt/minecraft/server/server.properties && echo "" && echo ${GRN}"Minecraft Server now set to private"${NC} && echo ""
            ;;
            2)
                echo "" && echo ${RED}"Now exiting whitelisting script."${NC} && echo ""
                exit
            ;;
            *)
            echo "Please only select option 1 or 2"
            continue ;;
          esac
          break
        done
fi

echo "Here is where you can input Minecraft usernames in order to whitelist them." && echo "" && echo ${GRN}"Please enter a Minecraft username you'd like to whitelist:"${NC} 
        while true; do
          read -r -p "When you are done, you can enter Q in order to quit." mc_username
          case "$mc_username" in
            Q)
                exit
            ;;
            q)
                exit
            ;;
            *)
                sudo /opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P $rcon_port -p $rcon_password -w 1 "whitelist add $mc_username"
            continue ;;
          esac
          break
        done

echo "" && echo "Now exiting whitelisting script."
