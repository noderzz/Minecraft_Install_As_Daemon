#!/bin/bash
####################################################################################################################################################
################################################                     Variables                     #################################################
####################################################################################################################################################

answer=""
javacheck=""
rcon_port=25575
rcon_password=""
total_mem=""
minecraft_mem=""

####################################################################################################################################################
################################################                     Functions                     #################################################
####################################################################################################################################################

set_resources () {
   total_mem=`free -h | grep Mem | cut -d ":" -f2 | cut -d "." -f1 | tr -d " "`
   echo "It looks like you have a total of "$total_mem"G of memory."
   echo "It may not be the best idea to use all available memory for the server, how much ram would you like to use to run the minecraft server?"
   read minecraft_mem
   if [ "$minecraft_mem" -gt "$total_mem" ]; then
     clear
     echo "You don't seem to have that much memory available."
     set_resources
   else
     minecraft_mem=$((minecraft_mem*1024))
   fi
}

systemd_unit_creation () {
  echo "
[Unit]
Description=Minecraft Server
After=network.target

[Service]
User=minecraft
Nice=1
KillMode=none
SuccessExitStatus=0 1
ProtectHome=true
ProtectSystem=full
PrivateDevices=true
NoNewPrivileges=true
WorkingDirectory=/opt/minecraft/server
ExecStart=/usr/bin/java -Xmx"$minecraft_mem"M -Xms"$minecraft_mem"M -jar server.jar nogui
ExecStop=/opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P "$rcon_port" -p "$rcon_password" stop

[Install]
WantedBy=multi-user.target" > ~/test.txt && sudo mv ~/test.txt /etc/systemd/system/minecraft.service
}

create_backup_file () {
  echo "
#!/bin/bash

function rcon {
  /opt/minecraft/tools/mcrcon/mcrcon -H 127.0.0.1 -P "$rcon_port" -p "$rcon_password" "$1"
}

rcon "save-off"
rcon "save-all"
tar -cvpzf /opt/minecraft/backups/server-$(date +%F-%H-%M).tar.gz /opt/minecraft/server
rcon "save-on"

## Delete older backups
find /opt/minecraft/backups/ -type f -mtime +7 -name '*.gz' -delete

  " > test.txt && sudo mv test.txt /opt/minecraft/tools/backup.sh
}


####################################################################################################################################################
###################################################                     Code                     ###################################################
####################################################################################################################################################

#####  Check if you have priviledged access  #####
clear
echo "This script must be run as a user with root privileges."
echo "Now checking if current user has root privileges"
  sleep 2
  answer=`sudo whoami`

if [ "$answer" != "root" ]; then 
  echo "It doesn't appear that your user has root privileges."
  sleep 1
  echo "Please login as a user with sudo/root privileges and try again."
  sleep 1
  echo "Now exiting script."
  exit 1
else
  echo "It appears this user has root privileges."
  sleep 1
  echo "Now running Java check."
  sleep 1
fi


#####  Update the Server/Check Java Runtime and Install if missing  #####
javacheck=`java -version 2>&1 | grep version | cut -d '"' -f2 | cut -d "." -f1`
if [ "$javacheck" = 16 ] || [ "$javacheck" = 17 ] || [ "$javacheck" = 18 ]; then 
  echo "Java version is "$javacheck"."
else
  echo "Java version not detected or too old, installing Java now."
  sudo apt install openjdk-18-jre-headless -y
fi

#####  Create Minecraft User & Install server as that user  #####
echo "Creating Minecraft system user to run Minecraft server"
sudo useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft
sleep 3
echo "Minecraft User Added"
echo ""
echo "Creating Minecraft Server Directories and Installing Server"
sleep 2
sudo -u minecraft bash -c 'mkdir -p ~/{backups,tools,server}'
sudo -u minecraft bash -c 'git clone https://github.com/Tiiffi/mcrcon.git ~/tools/mcrcon'
sudo apt-get install gcc -y
sudo -u minecraft bash -c 'gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o ~/tools/mcrcon/mcrcon ~/tools/mcrcon/mcrcon.c'
sudo -u minecraft bash -c 'wget https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar -P ~/server'
sudo -u minecraft bash -c 'cd ~/server && java -Xmx1024M -Xms1024M -jar server.jar nogui'
sudo sed -i "s/\("eula" *= *\).*/\1true/" /opt/minecraft/server/eula.txt
echo "Server Installed"


#####  Configure Minecraft Server/RCON  #####
echo "Now Configuring RCON"
echo "Please give me an RCON port.  If you'd like to use the default of \"25575\" then please leave this blank and just hit enter"
  read rcon_port
if [ "$rcon_port" = "" ]; then
  rcon_port=25575
  echo "rcon port is set to DEFAULT: "$rcon_port
else
  echo "rcon port is now: "$rcon_port
fi

echo "Please give me an RCON password.  This should be relatively secure."
  read rcon_password
sudo sed -i "s/\("rcon.port" *= *\).*/\1$rcon_port/" /opt/minecraft/server/server.properties
sudo sed -i "s/\("rcon.password" *= *\).*/\1$rcon_password/" /opt/minecraft/server/server.properties
sudo sed -i "s/\("enable-rcon" *= *\).*/\1true/" /opt/minecraft/server/server.properties

#####  Create Systemd Unit File/Adjust Firewall  #####
#Set Resources for Server
set_resources
#Create Systemd Unit File and start the daemon
systemd_unit_creation
sudo systemctl daemon-reload
sudo systemctl start minecraft
#Open up ports in firewall
sudo ufw allow 25565/tcp

#####  Configure Backups  #####
#Create the backup file
create_backup_file
sudo chown minecraft:minecraft /opt/minecraft/tools/backup.sh
sudo chmod +x /opt/minecraft/tools/backup.sh
#Add this shell script to the crontab
sudo -u minecraft bash -c 'echo "0 23 * * * /opt/minecraft/tools/backup.sh" | crontab -'