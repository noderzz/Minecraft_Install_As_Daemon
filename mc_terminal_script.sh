#!bin/bash
clear
#variables
CYN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'
is_mc_server_running=""
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

#Open terminal
clear
echo "This is the MC terminal to input server commands." && echo ""
echo ${RED}"If you just downloaded the server and are seeing an error stating you cannot connect, please wait 5-10 minutes for the Minecraft Server to fully spin up and try again." && echo "" 
echo ${NC}"If you want more information on what commands you can use, visit https://minecraft.fandom.com/wiki/Commands"
echo "(You don't need to start any commands with the '/').  Example - To make someone a server operator you'd run:"
echo "" && echo ${CYN}"op MINECRAFT_USERNAME"${NC} && echo "" 

sudo /opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P $rcon_port -p $rcon_password