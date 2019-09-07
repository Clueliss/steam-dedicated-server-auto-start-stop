#!/bin/bash

set -e

if [[ $# > 0 ]] && [[ $1 == "--docker" ]]; then
    cp scripts/docker/mcserv-shutdown-timerctrl /usr/bin
    cp systemd-units/docker/* /etc/systemd/system
else
    cp scripts/default/* /usr/bin
    cp systemd-units/default/* /etc/systemd/system
fi

cp systemd-units/*.* /etc/systemd/system
chmod +x /usr/bin/mcserv-*

echo "Success"
