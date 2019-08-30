#!/bin/bash

if [[ $# < 1 ]]; then
    echo "Usage: configure PATH_TO_MCSERVER"
    exit 1
fi

to_edit=(systemd-units/mcserv.service systemd-units/mcserv-stoptimerctrl.service)

for f in "${to_edit[@]}"; do
    sed -i 's!/opt/mcserv!'$1'!g' "$f"
done
