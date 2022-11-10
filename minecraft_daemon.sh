#!/bin/bash

#################
### Variables ###
#################

answer=""
javacheck=""
rcon_port=25575
rcon_password=""
total_mem=""
minecraft_mem=""
current_mc_version="1.19.2"
user_response=""
user_url=""
quick_check=""
mc_server_difficulty=""
mc_seed=""
world_name=""
is_mc_server_running=""
local_ip=`ip a | grep brd | grep inet | cut -d/ -f1 | cut -d" " -f6`

#################
### Functions ###
#################

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

server_download_check () {
  quick_check=`echo $user_url | grep "server.jar"`
  if [ "$quick_check" = "" ]; then
        echo "It doesn't appear that the link downloads a Minecraft Server."
        echo "Would you like to try again?"
        echo "
        1) Yes
        2) No
        "
        while true; do
          read -r -p 'Please select option "1" or "2": ' user_response
          case "$user_response" in
            1)
            clear
            enter_minecraft_server_version
            ;;
            2)
            exit
            ;;
            *)
            echo "Please only select option 1 or 2"
            continue ;;
          esac
          break
        done
  fi
}

server_customize () {
  echo "Would you like to add a server seed, world name and difficulty setting?"
  echo ""
  echo "
  (1) No, please generate a random seed and use all default settings.
  (2) Yes, I'd like to input these settings.

  "
    while true; do
      read -r -p 'Please select option "1" or "2": ' user_response
      case "$user_response" in
        1)
          break
        ;;
        2)
            echo "What would you like the difficulty setting set to?"
            echo ""
            echo "
            (1) Peaceful
            (2) Easy
            (3) Normal
            (4) Hard
             "
              while true; do
                read -r -p 'Please select option "1" or "2": ' user_response
                case "$user_response" in
                  1)
                    mc_server_difficulty="peaceful"
                  ;;
                  2)
                    mc_server_difficulty="easy"
                  ;;
                  3)
                    mc_server_difficulty="normal"
                  ;;
                  4)
                    mc_server_difficulty="hard"
                  ;;
                  *)
                    echo "Please only select an option between 1-4."
                  continue ;;
                esac
                break
              done
              echo "What would you like for the seed?"
                read mc_seed
              echo ""
              echo "What would you like for the world name?"
                read world_name
              echo ""
              echo "Now setting up server settings."
              sudo sed -i "s/\("difficulty" *= *\).*/\1$mc_server_difficulty/" /opt/minecraft/server/server.properties
              sudo sed -i "s/\("level-seed" *= *\).*/\1$mc_seed/" /opt/minecraft/server/server.properties
              sudo sed -i "s/\("level-name" *= *\).*/\1$world_name/" /opt/minecraft/server/server.properties

        ;;
        *)

        continue ;;
      esac
      break
    done
}

enter_minecraft_server_version () {
  echo "Currently this script installs Minecraft version "$current_mc_version"."
  echo "What would you like to do?"
  echo "
  (1) Continue with the "$current_mc_version" Install.
  (2) Enter the URL for the MC Server version myself. (Choose this option if you want to install a newer/older version)

  "
    while true; do
      read -r -p 'Please select option "1" or "2": ' user_response
      case "$user_response" in
        1)
           echo "Downloading latest Minecraft Server version."
           sudo -u minecraft bash -c 'wget https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar -P ~/server' && echo "Minecraft server downloaded"
           sleep 2
           sudo -u minecraft bash -c 'cd ~/server && java -Xmx1024M -Xms1024M -jar server.jar nogui'
           sudo sed -i "s/\("eula" *= *\).*/\1true/" /opt/minecraft/server/eula.txt && echo "Server Installed"
        ;;
        2)
        echo "Please paste in the URL for the Minecraft Server you'd like to download: "
          echo ""
          read user_url
            server_download_check
            echo "Downloading Minecraft Server from your URL:"
            sudo -u minecraft bash -c "wget $user_url -P ~/server" && echo "Minecraft server downloaded"
            sleep 2
            sudo -u minecraft bash -c 'cd ~/server && java -Xmx1024M -Xms1024M -jar server.jar nogui'
            sudo sed -i "s/\("eula" *= *\).*/\1true/" /opt/minecraft/server/eula.txt && echo "Server Installed"
        ;;
        *)
        clear
        echo "Invalid option"
        echo 'Please select option "1" or "2"'
          echo ""
          echo "Currently this script installs Minecraft version "$current_mc_version"."
          echo "What would you like to do?"
          echo "
          (1) Continue with the "$current_mc_version" Install.
          (2) Enter the URL for the MC Server version myself. (Choose this option if you want to install a newer/older version)
          "
        continue ;;
      esac
      break
    done
}


  
  


#################
##### Code ######
#################

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
fi


#####  Update the Server/Check Java Runtime and Install if missing  #####
  echo "Now running Java check."
  echo ""
  sleep 1
javacheck=`java -version 2>&1 | grep version | cut -d '"' -f2 | cut -d "." -f1`
if [ "$javacheck" = 16 ] || [ "$javacheck" = 17 ] || [ "$javacheck" = 18 ]; then 
  echo "Java version is "$javacheck"."
  echo ""
  sleep 2
else
  echo "Java version too old or not detected."
  echo ""
  sleep 2
  sudo apt install openjdk-18-jre-headless -y
fi

#####  Create Minecraft User & Install server as that user  #####
clear
echo "Creating Minecraft system user to run Minecraft server"
echo ""
sudo useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft && echo "Minecraft User Added"
sleep 3
echo "" && echo "Creating Minecraft Server Directories and Installing Server"
    sleep 2
    echo ""
    sudo -u minecraft bash -c 'mkdir -p ~/{backups,tools,server}' && echo '"backups", "tools" and "server" directories created.'
    sleep 2
    clear
    echo "Now installing mcrcon"
    echo ""
    sudo -u minecraft bash -c 'git clone https://github.com/Tiiffi/mcrcon.git ~/tools/mcrcon' && echo "mcrcon successfully downloaded"
    echo "Now installing GCC"
    sudo apt-get install gcc -y && echo "GCC Successfully Installed"
    sleep 2
    echo "Now completing mcrcon installation."
    sudo -u minecraft bash -c 'gcc -std=gnu11 -pedantic -Wall -Wextra -O2 -s -o ~/tools/mcrcon/mcrcon ~/tools/mcrcon/mcrcon.c' && echo "mcrcon successfully installed"
    sleep 2
    clear

#Choose the MC Server Version
enter_minecraft_server_version


#####  Configure Minecraft Server/RCON  #####
clear
echo "Now Configuring RCON"
echo "Please give me an RCON port.  If you'd like to use the default of \"25575\" then please leave this blank and just hit enter"
    read rcon_port
      if [ "$rcon_port" = "" ]; then
        rcon_port=25575
        echo "rcon port is set to DEFAULT: "$rcon_port
        echo ""
      else
        echo "rcon port is now: "$rcon_port
        echo ""
      fi
echo "Please give me an RCON password.  This should be relatively secure."
  read rcon_password
  echo ""
    sudo sed -i "s/\("rcon.port" *= *\).*/\1$rcon_port/" /opt/minecraft/server/server.properties
    sudo sed -i "s/\("rcon.password" *= *\).*/\1$rcon_password/" /opt/minecraft/server/server.properties
    sudo sed -i "s/\("enable-rcon" *= *\).*/\1true/" /opt/minecraft/server/server.properties

server_customize

#####  Create Systemd Unit File/Adjust Firewall  #####
#Set Resources for Server
set_resources
#Create Systemd Unit File and start the daemon
clear
echo "Now creating Minecraft Systemd Unit File."
  sleep 2
    systemd_unit_creation
    sudo systemctl daemon-reload
    sudo systemctl start minecraft
echo ""
#Open up ports in firewall
echo "Now opening up firewall for Minecraft server."
  sudo ufw allow 25565/tcp
    echo ""

#####  Configure Backups  #####
#Create the backup file
echo "Now creating Minecraft world backup script."
  create_backup_file
  sudo chown minecraft:minecraft /opt/minecraft/tools/backup.sh && echo "Minecraft backup script created successfully"
  sudo chmod +x /opt/minecraft/tools/backup.sh
    echo ""
#Add this shell script to the crontab
echo "Adding backup script to crontab"
  sudo -u minecraft bash -c 'echo "0 23 * * * /opt/minecraft/tools/backup.sh" | crontab -' && echo "Done!"
  sleep 2
    echo ""

#Displaying Minecraft Server
clear
is_mc_server_running=`sudo systemctl status minecraft | grep Active | cut -d: -f2 | cut -d" " -f2`
if [ "$is_mc_server_running" != "active" ]; then
    echo "Unfortunately it looks like the Minecraft server is not running."
    echo 'You may want to try running "sudo systemctl restart minecraft".'
    exit
else
    echo "Minecraft Server Installation Complete!"
    echo "Try having users connect to the IP "$local_ip
    exit
fi

