# Minecraft Server Auto-StartStop

## Introduction

> This is a collection of bash scripts and systemd-units that will allow a Minecraft Server to:  
> - automatically start when players try to join  
> - automatically stop after X (default 15min) minutes when no players are online  

## How it works
> Since Minecraft does not natively support Socket Activation there is some trickery involved.
> Firstly the Minecraft Server needs to run on a different Port then the default (25565).
> A Systemd Socket (mcserv.socket) then listenes on Port 25565, if it received traffic it starts mcserv.service which will:
> 1. forward tcp and udp port 25565 to port 25555 (the port the minecraft server will be running on, see _Configuration_)
> 2. start mcserv-stoptimerctrl.service
> 3. start the minecraft server

> While the Server is running, mcserv-stoptimerctrl.service will monitor the servers playercount, through reading the serverlog.
> Therefore since i have not found a suitable solution to monitor journald logs (which is currently required to monitor the playercount, i may switch to using 'screen' in the future), the log has to be redirected to /opt/mcserv/server.log.

> If the playercount reaches 0 it will start mcserv-stop.timer, which will stop the minecraftserver after x minutes (therefore stopping mcserv-stoptimerctrl.service and removing the port forwards).  

> If the playercount becomes > 0 while the timer is started, the timer is stopped. 

## Problems
> Since starting a Minecraftserver can take it's time (30sec in my case). Initially connecting players may experience a timeout during the first try.
> Try joining again after the first try.

## Dependencies
> - bash
> - systemd
> - firewalld

## Configuration
> \- Go to your Minecraft Server Directory and change the server-port (in server.properties) to 25555
> \- If your minecraft server does not live in /opt/mcserv you will need to edit the WorkingDirectory and Exec paths in 
> - mcserv.service
> - mcserv-stoptimerctrl.service

> Info: I may add an automatic configuration script in the future.

## Installation
> \# bash install.sh  
> \# systemctl daemon-reload  
> \# systemctl enable mcserv.socket --now
