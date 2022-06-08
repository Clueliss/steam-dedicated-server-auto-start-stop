#!/bin/bash

get_unit_var() {
    local unit_name="$1"
    local var_name="$2"

    local override_conf="/etc/systemd/system/${unit_name}.d/override.conf"

    if [[ -f $override_conf ]]; then
        cat $override_conf | grep "${var_name}=" | sed "s/${var_name}=//"
    else
        cat /etc/systemd/system/${unit_name} | grep "${var_name}=" | sed "s/${var_name}=//"
    fi
}

override_unit() {
    local unit_name="$1"
    local override_content="$2"

    local override_path="/etc/systemd/system/${unit_name}.d"
    local override_conf="${override_path}/override.conf"

    mkdir $override_path || true
    echo -e "$override_content" >| $override_conf
}

if [[ -n $DDSERV_UID ]] && [[ $(id -u ddserv) != $DDSERV_UID ]]; then
    echo "<6> setting UID of ddserv to $DDSERV_UID"
    usermod --non-unique --uid "$DDSERV_UID" ddserv
fi

if [[ -n $DDSERV_GID ]] && [[ $(id -g ddserv) != $DDSERV_GID ]]; then
    echo "<6> setting GID of ddserv to $DDSERV_GID"
    groupmod --non-unique --gid "$DDSERV_GID" ddserv
fi

chown -R ddserv:ddserv /home/ddserv

if [[ -n "$DDSERV_PASSWORD" ]]; then
    echo "<6> changing PASSWORD of ddserv"
    echo "ddserv:$DDSERV_PASSWORD" | chpasswd
fi


if [[ -n "$DDSERV_TIMEOUT" ]] && [[ "$(get_unit_var dedicated-server-stop.timer OnActiveSec)" != "$DDSERV_TIMEOUT" ]]; then
    echo "<6> setting TIMEOUT to $DDSERV_TIMEOUT"
    override_unit dedicated-server-stop.timer "[Timer]\nOnActiveSec=$DDSERV_TIMEOUT"
fi

if [[ -n $DDSERV_ACTIVATE_PORT ]]; then
    port=$(echo $DDSERV_ACTIVATE_PORT | cut -d/ -f1)
    proto=$(echo $DDSERV_ACTIVATE_PORT | cut -d/ -f2)

    case $proto in
        tcp)
            if [[ $(get_unit_var dedicated-server.socket ListenStream) != $port ]]; then
                echo "<6> setting ACTIVATE_PORT to $port/tcp"
                override_unit dedicated-server.socket "[Socket]\nListenDatagram=\nListenStream=$port"
            fi
            ;;
        udp)
            if [[ $(get_unit_var dedicated-server.socket ListenDatagram) != $port ]]; then
                echo "<6> setting ACTIVATE_PORT to $port/udp"
                override_unit dedicated-server.socket "[Socket]\nListenStream=\nListenDatagram=$port"
            fi
            ;;
        *)
            echo "<3> error setting ACTIVATE_PORT unknown protocol $proto" 2>&1
            exit 1
            ;;
    esac
fi

if [[ -n $DDSERV_EXIT_SUCCESS_CODE ]] && [[ $(get_unit_var dedicated-server.service SuccessExitStatus) != $DDSERV_EXIT_SUCCESS_CODE ]]; then
    echo "<6> setting EXIT_SUCCESS_CODE to $DDSERV_EXIT_SUCCESS_CODE"
    override_unit dedicated-server.service "[Service]\nSuccessExitStatus=$DDSERV_EXIT_SUCCESS_CODE"
fi

if [[ -z $DDSERV_STEAM_APP_ID ]]; then
    echo '<3> you forgot to specify an app id, please do that and then restart the container' 2>&1
elif [[ -f /opt/dedicated-server/.installed-app ]]; then
    if [[ $(cat /opt/dedicated-server/.installed-app) != $DDSERV_STEAM_APP_ID ]]; then
        echo '<3> the specified app id does not match the installed app, please backup your files, remove .installed-app and restart the container' 2>&1
    fi
else
    if [[ -n $DDSERV_STEAM_FORCE_PLATFORM ]]; then
        force_platform="+@sSteamCmdForcePlatformType $DDSERV_STEAM_FORCE_PLATFORM"
    fi

    echo "<6> starting download of dedicated server..."
    su --shell /bin/bash --command "steamcmd +force_install_dir /opt/dedicated-server $force_platform +login anonymous +app_update $DDSERV_STEAM_APP_ID validate +quit" - ddserv
    su --shell /bin/bash --command "echo $DDSERV_STEAM_APP_ID >| /opt/dedicated-server/.installed-app" - ddserv
fi

systemctl daemon-reload
