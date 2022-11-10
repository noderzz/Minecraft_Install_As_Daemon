#!bin/bash
clear
#variables
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
echo "If you want more information on what commands you can use, visit https://minecraft.fandom.com/wiki/Commands"
echo "(You don't need to start any commands with the '/').  Example - To make someone a server operator you'd run:"
echo "" && echo "op MINECRAFT_USERNAME" && echo "" 

sudo /opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P $rcon_port -p $rcon_password