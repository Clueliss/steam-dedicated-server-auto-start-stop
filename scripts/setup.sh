#!/bin/bash

get_current_timeout() {
    if [[ -f /etc/systemd/system/mcserv-stop.timer.d/override.conf ]]; then
        cat /etc/systemd/system/mcserv-stop.timer.d/override.conf | grep 'OnActiveSec=' | sed 's/OnActiveSec=//'
    fi

    cat /etc/systemd/system/mcserv-stop.timer | grep 'OnActiveSec=' | sed 's/OnActiveSec=//'
}

if [[ $(id -u minecraft) != $MINECRAFT_UID ]]; then
    usermod --non-unique --uid "$MINECRAFT_UID" minecraft
fi

if [[ $(id -g minecraft) != $MINECRAFT_GID ]]; then
    groupmod --non-unique --gid "$MINECRAFT_GID" minecraft
fi

if [[ $MINECRAFT_TIMEOUT != $(get_current_timeout) ]]; then
    mkdir /etc/systemd/system/mcserv-stop.timer.d || true
    echo -e "[Timer]\nOnActiveSec=$MINECRAFT_TIMEOUT" >| /etc/systemd/system/mcserv-stop.timer.d/override.conf
    systemctl daemon-reload
fi
