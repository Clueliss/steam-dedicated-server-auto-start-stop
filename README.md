# Steam Dedicated Server Auto-Start/Stop

## Introduction

This is a collection of bash scripts and systemd-units that will allow a steam dedicated server to:  
- automatically start when players try to join  
- automatically stop after some timespan X (default 15min) when no players are online  

## How it works
It is based on my minecraft-server-start-stop-ctrl repo and works the exact same way, just generalized to steam dedicated servers.

## Build Parameters
- `PINCLUDE_COCKPIT`: Whether to include the cockpit web ui in the image. Possible values: `0`, `1`. Default: `1`.
- `PINCLUDE_FTP`: Whether to include an FTP server in the image. Possible values: `0`, `1`. Default: `1`.
- `PADDITIONAL_PACKAGES`: A space seperated list of additional packages to install. Default: ``.

## Environment Variables

Setting any of these to the empty string means the setup script will not modify the currently
set value, whatever it is.

### Mandatory
- `DDSERV_STEAM_APP_ID`: The steam app id of the dedicated server.

- `DDSERV_ACTIVATE_PORT`: The port to listen on for inital traffic that triggers the server start. This should be the same as the dedicated server's port.
    Format: `$port/$proto`
    Default: `27015/udp`.

- `DDSERV_LOG_SOURCE`: Where to get the connection logs from. Possible values: `journald`, `file`. `journald` means it will take the logs from stdout of the server.
    Default: `journald`.

- `DDSERV_LOG_FILE`: If `DDSERV_LOG_SOURCE` == `file` then this should be set to the path of the logfile.
    Default: not set.
- `DDSERV_JOIN_PATTERN`: A regex that matches _only_ a player join message in the log.
- `DDSERV_LEAVE_PATTERN`: A regex that matches _only_ a player leave message in the log.

- `DDSERV_EXIT_SUCCESS_CODE`: Set the to the exit code the server returns when successfully closing. Usually this should be 0, but in practice it often isn't; e.g. for Minecraft it is 143.
    Default: `0`.

### Optional
- `DDSERV_UID`: The uid of the user that runs the dedicated server. Default: `0`.
- `DDSERV_GID`: The gid of the user that runs the dedicated server. Default: `0`.
- `DDSERV_PASSWORD`: The password for the `ddserv` user (e.g. for use with FTP). Default: no password.

- `DDSERV_STEAM_FORCE_PLATFORM`: Force steamcmd to download content for a specific platform, this is usually empty or set to `windows`. Default: not set.

- `DDSERV_KILL_MODE`: How systemd is supposed to kill the server (see [systemd.kill#KillMode](https://www.freedesktop.org/software/systemd/man/systemd.kill.html)). Only necessary if the server does not shut down correctly with the default. Default: `control-group`.

- `DDSERV_TIMEOUT`: The time to wait before shutting down if no players are online. Default: `15min`.

- `DDSERV_COCKPIT_PORT`: The port for the (optional) cockpit web ui. Format: `$port`. Default: `9090`.
- `DDSERV_FTP_PORT`: The port for the (optional) FTP server. Format: `$port`. Default: `21`.


## Volumes and important files
- `/opt/dedicated-server`: this is where all the dedicated server files will be put
- `/opt/dedicated-server/start_server`: an executable script (provided by you) that starts the dedicated server

### Ports
- `$DDSERV_COCKPIT_PORT/tcp` (if enabled): cockpit web interface
- `$DDSERV_FTP_PORT/tcp` (if enabled): FTP server
- and whatever port(s) the dedicated server runs on
