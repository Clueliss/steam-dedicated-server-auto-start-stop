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
> If the playercount reaches 0 it will start mcserv-stop.timer, which will stop the minecraftserver after x minutes (therefore stopping mcserv-stoptimerctrl.service and restarting mcserv.socket).  

> If the playercount becomes > 0 while the timer is started, the timer is stopped.

## Problems
> Initially connecting players will experience a connection closed error message, since the mcserv.socket first bound to port 25565 and is then stopped (which it has to, i think; maybe i'm missing some feature in systemd)
> Solution: Try joining again.

## Dependencies
> - bash
> - systemd

## Podman Compose (< v1.0)
- change the UID and GID in scripts/mcserv-start.sh to the IDs of your minecraft user, this is to drop privileges before starting the server
- > $ podman-compose up -d

## Manual Install

### Configuration
If your minecraft server does not live in /opt/mcserv and you are not using podman you need to run  
> $ ./manual_deploy/configure.sh YOUR_MCSERVER_DIR

### Installation
> \# ./manual_deploy/install.sh

### Starting
> \# systemctl start mcserv.socket

### Uninstall
> \# ./manual_deploy/uninstall.sh
