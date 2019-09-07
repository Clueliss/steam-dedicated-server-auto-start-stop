#!/bin/bash

set -e

if [[ $# < 1 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    echo "Usage: configure PATH_TO_MCSERVER"
    exit 1
fi

sed -i 's!/opt/mcserv!'$1'!g' systemd-units/default/mcserv.service
sed -i 's!/opt/mcserv!'$1'!g' scripts/default/mcserv-start

echo "Successfully set server path to $1"