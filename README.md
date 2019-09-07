# Minecraft Server Auto-StartStop

## Introduction

> This is a collection of bash scripts and systemd-units that will allow a Minecraft Server to:  
> - automatically start when players try to join  
> - automatically stop after X (default 15min) minutes when no players are online  

## How it works
> Since Minecraft does not natively support socket activation there is some trickery involved.
> Firstly there is the systemd socket mcserv.socket which listenes on Port 25565, if it receives traffic it starts mcserv.service which will:
> 1. stop mcserv.socket (since it conflics)
> 2. start mcserv-stoptimerctrl.service
> 3. start the minecraft server through /opt/mcserv/scripts/start.sh

> While the Server is running, mcserv-stoptimerctrl.service will monitor the servers playercount, through reading the serverlog.
> Therefore since i have not found a suitable solution to monitor journald logs the log has to be redirected to /opt/mcserv/server.log.

> If the playercount reaches 0 it will start mcserv-stop.timer, which will stop the minecraftserver after x minutes (therefore stopping mcserv-stoptimerctrl.service and restarting mcserv.socket).  

> If the playercount becomes > 0 while the timer is started, the timer is stopped.

## Problems
> Initially connecting players will experience a connection closed error message, since the mcserv.socket first bound to port 25565 and is then stopped (which it has to, i think; maybe i'm missing some feature in systemd)
> Solution: Try joining again.

## Dependencies
> - bash
> - systemd

## Configuration
> If your minecraft server does not live in /opt/mcserv and you are not using docker you need to run  
> $ bash ./configure.sh MCSERVER_DIR

## Docker installation (with Hamachi)
> \# docker run -d \\  
    --name="Hamachi" \\  
    --net="host" \\  
    --privileged="true" \\  
    -e ACCOUNT="your@email.com" \\  
    -v "/mnt/cache/appdata/Hamachi/":"/config":rw \\  
    -v "/etc/localtime":"/etc/localtime":ro \\  
    gfjardim/hamachi

> $ docker build .
> \# docker run --net="host" -v MCSERVER_DIR:/mcserv ID_GIVEN_BY_PREVIOUS_COMMAND
> \# bash ./install.sh --docker

## Docker installation (without Hamachi)
> $ docker build .
> \# docker run -v MCSERVER_DIR:/mcserv -p 25565:25565 ID_GIVEN_BY_PREVIOUS_COMMAND
> \# bash ./install.sh --docker

## Installation
> \# bash ./install.sh  

## Starting
> \# systemctl start mcserv.socket
