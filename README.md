# Minecraft Server Auto-StartStop

## Introduction

This is a collection of bash scripts and systemd-units that will allow a Minecraft Server to:  
- automatically start when players try to join  
- automatically stop after X (default 15min) minutes when no players are online  

## How it works
Since Minecraft does not natively support socket activation there is some trickery involved.
1. Firstly there is the systemd socket mcserv.socket which listenes on Port 25565, if it receives traffic it starts mcserv.service which will:
    1. stop mcserv.socket (since it conflics)
    2. start mcserv-stoptimerctrl.service
    3. start the minecraft server through mcserv-start.sh

2. While the Server is running, mcserv-stoptimerctrl.service will monitor the servers playercount, through reading the serverlog.
3. If the playercount reaches 0 it will start mcserv-stop.timer, which will stop the minecraftserver after x minutes (therefore stopping mcserv-stoptimerctrl.service and restarting mcserv.socket).  

4. If the playercount becomes > 0 while the timer is started, the timer is stopped.

## Limitations
- Initially connecting players will experience a connection closed error message, since the mcserv.socket first bound to port 25565 and is then stopped. I don't know of any mechanism to give the open socket to the minecraft server. <br>
Just try joining again after some time when the server is up and running.

## Environment Variables
- `MINECRAFT_UID`: the uid of the user that runs minecraft the default is root but you should probably change that
- `MINECRAFT_GID`: the gid of the user that runs minecraft the default is root but you should probably change that
- `MINECRAFT_PASSWORD`: the password for the minecraft user (for use with ftp)
- `MINECRAFT_SERVER_JAR`: the filename of the server jar
- `MINECRAFT_JVM_ARGS`: the arguments passed to the java-virtual-machine. Since they are often very long consider unsing a [.env](https://docs.docker.com/compose/environment-variables/#the-env-file) file.
- `MINECRAFT_JAR_ARGS`: the arguments passed to the minecraft server jar

### Ports
- `25565/tcp`: minecraft
- `25565/udp`: minecraft
- `8000/tcp`: systemd-query-rest
- `21/tcp`: ftp
