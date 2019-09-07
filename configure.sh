#!/bin/bash

if [[ $# < 1 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    echo "Usage: configure PATH_TO_MCSERVER"
    exit 1
fi

to_edit=(install.sh uninstall.sh systemd-units/mcserv.service systemd-units/mcserv-stoptimerctrl.service)

for f in "${to_edit[@]}"; do
    sed -i 's!/opt/mcserv!'$1'!g' "$f"
done
