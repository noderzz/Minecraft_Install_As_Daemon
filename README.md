<h1>Install Vanilla Minecraft Server as a Daemon</h1>

<h2>Description</h2>
This project is a semi-automated script for installing a vanilla Minecraft server, version 1.19.2, on your Debian device.
<br />


<h2>Languages and Utilities Used</h2>

- <b>Bash</b> 

<h2>Environments Used </h2>

- <b>Ubuntu 20.04</b> 

<h2>Program walk-through:</h2>

<h4>Clone the repository and go into the directory</h4>
<p align="center">
<img src="https://imgur.com/4Oj7BEW.png" alt="Clone GitHub Repository" class="center">
</p>

```
git clone https://github.com/noderzz/Minecraft_Install_As_Daemon.git
cd Minecraft_Install_As_Daemon
```

<h4>Make the mc_terminal_script.sh executable and run it.</h4>

```
chmod +x minecraft_daemon.sh
./minecraft_daemon.sh
```
<h4>Input an RCON port and password.</h4>
<br />
<br />
<h4>Select amount of memory to run server with.</h4>
<br />
<br />
<h4>Verify server is running.</h4>
<br />
<br />
<h4>Run mc_terminal_script.sh to run server commands on the newly installed Minecraft Server</h4>
<i>Be sure to wait 5-10 minutes after running the <strong>minecraft_daemon.sh</strong> script before running the <strong>mc_terminal_script.sh</strong> script.  The server will need a few minutes to generate the world and if you're too quick to run the script you may give an error stating that the terminal script could not connect.</i>
<br></br>

```
chmod +x mc_terminal_script.sh
./mc_terminal_script.sh
```

<!--
 ```diff
- text in red
+ text in green
! text in orange
# text in gray
@@ text in purple (and bold)@@
```
--!>
