#!/bin/bash

get_unit_var() {
    local unit_name="$1"
    local var_name="$2"

    systemctl cat $unit_name | grep "${var_name}=" | tail -n1 | sed "s/${var_name}=//"
}

override_unit() {
    local unit_name="$1"
    local override_content="$2"

    local override_path="/etc/systemd/system/${unit_name}.d"
    local override_conf="${override_path}/override.conf"

    mkdir $override_path || true
    echo -e "$override_content" >| $override_conf
}

set_uid() {
    if [[ -n $DDSERV_UID ]] && [[ $(id -u ddserv) != $DDSERV_UID ]]; then
        echo "<6>setting UID of ddserv to $DDSERV_UID"
        usermod --non-unique --uid "$DDSERV_UID" ddserv
    fi
}

set_gid() {
    if [[ -n $DDSERV_GID ]] && [[ $(id -g ddserv) != $DDSERV_GID ]]; then
        echo "<6>setting GID of ddserv to $DDSERV_GID"
        groupmod --non-unique --gid "$DDSERV_GID" ddserv
    fi
}

chown_home() {
    chown -R ddserv:ddserv /home/ddserv
}

set_password() {
    if [[ -n "$DDSERV_PASSWORD" ]]; then
        echo "<6>changing PASSWORD of ddserv"
        echo "ddserv:$DDSERV_PASSWORD" | chpasswd
    fi
}

configure_cockpit_port() {
    if systemctl cat cockpit.socket > /dev/null 2>&1; then
        rm -f /run/nologin

        if [[ -n $DDSERV_COCKPIT_PORT ]] && [[ $(get_unit_var cockpit.socket ListenStream) != $DDSERV_COCKPIT_PORT ]]; then
            echo "<6>setting COCKPIT_PORT to $DDSERV_COCKPIT_PORT"
            override_unit cockpit.socket "[Socket]\nListenStream=\nListenStream=$DDSERV_COCKPIT_PORT"
            
            systemctl daemon-reload
            systemctl restart cockpit.socket
        fi
    fi
}

configure_ftp_port() {
    if [[ -f /etc/vsftpd.conf ]] && [[ -n $DDSERV_FTP_PORT ]]; then
        local current_ftp_listen_port=$(cat /etc/vsftpd.conf | grep '^listen_port=' | sed 's/listen_port=//')

        if [[ $current_ftp_listen_port != $DDSERV_FTP_PORT ]]; then
            echo "<6>setting FTP port to $DDSERV_FTP_PORT"
            
            if [[ -z $current_ftp_listen_port ]]; then
                echo "listen_port=$DDSERV_FTP_PORT" >> /etc/vsftpd.conf
            else
                sed -i "s/listen_port=.*/listen_port=$DDSERV_FTP_PORT" /etc/vsftpd.conf
            fi

            systemctl restart vsftpd.service
        fi
    fi
}

configure_timeout() {
    if [[ -n "$DDSERV_TIMEOUT" ]] && [[ "$(get_unit_var dedicated-server-stop.timer OnActiveSec)" != "$DDSERV_TIMEOUT" ]]; then
        echo "<6>setting TIMEOUT to $DDSERV_TIMEOUT"
        override_unit dedicated-server-stop.timer "[Timer]\nOnActiveSec=$DDSERV_TIMEOUT"
    fi
}

configure_activate_port() {
    if [[ -n $DDSERV_ACTIVATE_PORT ]]; then
        local port=$(echo $DDSERV_ACTIVATE_PORT | cut -d/ -f1)
        local proto=$(echo $DDSERV_ACTIVATE_PORT | cut -d/ -f2)

        case $proto in
            tcp)
                if [[ $(get_unit_var dedicated-server.socket ListenStream) != $port ]]; then
                    echo "<6>setting ACTIVATE_PORT to $port/tcp"
                    override_unit dedicated-server.socket "[Socket]\nListenDatagram=\nListenStream=$port"
                fi
                ;;
            udp)
                if [[ $(get_unit_var dedicated-server.socket ListenDatagram) != $port ]]; then
                    echo "<6>setting ACTIVATE_PORT to $port/udp"
                    override_unit dedicated-server.socket "[Socket]\nListenStream=\nListenDatagram=$port"
                fi
                ;;
            *)
                echo "<3>error setting ACTIVATE_PORT unknown protocol $proto" 2>&1
                exit 1
                ;;
        esac
    fi
}

configure_exec_parameters() {
    if [[ -n $DDSERV_EXIT_SUCCESS_CODE ]] || [[ -n $DDSERV_KILL_MODE ]]; then
        local current_success_code=$(get_unit_var dedicated-server.service SuccessExitStatus)
        local current_kill_mode=$(get_unit_var dedicated-server.service KillMode)

        local override_str="[Service]"

        if [[ $current_success_code != $DDSERV_EXIT_SUCCESS_CODE ]]; then
            echo "<6>setting EXIT_SUCCESS_CODE to $DDSERV_EXIT_SUCCESS_CODE"
            override_str="${override_str}\nSuccessExitStatus=$DDSERV_EXIT_SUCCESS_CODE"
        fi

        if [[ $current_kill_mode != $DDSERV_KILL_MODE ]]; then
            echo "<6>setting KILL_MODE to $DDSERV_KILL_MODE"
            override_str="${override_str}\nKillMode=$DDSERV_KILL_MODE"
        fi

        override_unit dedicated-server.service "$override_str"
    fi
}

install_dedicated_server() {
    if [[ -z $DDSERV_STEAM_APP_ID ]]; then
        echo '<3>you forgot to specify an app id, please do that and then restart the container' 2>&1
    elif [[ -f /opt/dedicated-server/.installed-app ]]; then
        if [[ $(cat /opt/dedicated-server/.installed-app) != $DDSERV_STEAM_APP_ID ]]; then
            echo '<3>the specified app id does not match the installed app, please backup your files, remove .installed-app and restart the container' 2>&1
        fi
    else
        if [[ -n $DDSERV_STEAM_FORCE_PLATFORM ]]; then
            local force_platform="+@sSteamCmdForcePlatformType $DDSERV_STEAM_FORCE_PLATFORM"
        fi

        echo "<6>starting download of dedicated server..."
        su --command "steamcmd +force_install_dir /opt/dedicated-server $force_platform +login anonymous +app_update $DDSERV_STEAM_APP_ID validate +quit" - ddserv
        su --command "echo $DDSERV_STEAM_APP_ID >| /opt/dedicated-server/.installed-app" - ddserv
    fi
}

set_uid
set_gid
chown_home
set_password

configure_cockpit_port
configure_ftp_port

configure_timeout
configure_activate_port
configure_exec_parameters

systemctl daemon-reload

install_dedicated_server
