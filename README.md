# Steam Dedicated Server Auto-Start/Stop

## Introduction

This is a collection of bash scripts and systemd-units that will allow a steam dedicated server to:  
- automatically start when players try to join  
- automatically stop after some timespan X (default 15min) when no players are online  

## How it works
It is based on my minecraft-server-start-stop-ctrl repo and works the exact same way, just generalized to steam dedicated servers.

## Environment Variables
- `DDSERV_UID`: The uid of the user that runs the dedicated server. The default is root but you should change that.
- `DDSERV_GID`: The gid of the user that runs the dedicated server. The default is root but you should change that.
- `DDSERV_PASSWORD`: The password for the ddserv user (for use with ftp; login with `user: ddserv and password: $DDSERV_PASSWORD`).
- `DDSERV_EXIT_SUCCESS_CODE`: Set the to the exit code the server returns when successfully closing. Usually this should be 0, but in practice it often isn't; e.g. for Minecraft it is 143.
- `DDSERV_TIMEOUT`: The time to wait before shutting down if no players are online.
- `DDSERV_ACTIVATE_PORT`: The port to listen on for inital traffic that triggers the server start. Format: `port/proto`.
- `DDSERV_LOG_SOURCE`: Where to get the connection logs from. Possible values: `journald`, `file`. `journald` means it will take the logs from stdout of the server.
- `DDSERV_LOG_FILE`: If `DDSERV_LOG_SOURCE` == `file` then this should be set to the path of the logfile.
- `DDSERV_STEAM_APP_ID`: The steam app id of the dedicated server.
- `DDSERV_STEAM_FORCE_PLATFORM`: Force steamcmd to download content for a specific platform, this is usually empty or set to `windows`.
- `DDSERV_JOIN_PATTERN`: A regex that matches _only_ a player join message in the log.
- `DDSERV_LEAVE_PATTERN`: A regex that matches _only_ a player leave message in the log.

## Volumes and important files
- `/opt/dedicated-server`: this is where all the dedicated server files will be put
- `/opt/dedicated-server/start_server`: an executable script (provided by you) that starts the dedicated server

### Ports
- `8000/tcp`: systemd-query-rest
- `21/tcp`: ftp
- and whatever port the dedicated server runs on
