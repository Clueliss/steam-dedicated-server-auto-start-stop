#!/bin/bash

if [[ $# > 0 ]] && ([[ $1 == "--docker" ]]; then
    cp docker-scripts/shutdowntimer-ctrl.sh /opt/mcserv
else
    cp -r scripts /opt/mcserv
fi

cp systemd-units/* /etc/systemd/system
