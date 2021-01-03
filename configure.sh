#!/bin/bash

set -e

if [[ $# < 1 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
    echo "Usage: configure PATH_TO_MCSERVER"
    exit 1
fi

ls $1
sed -i "s#WorkingDirectory=/opt/mcserv#WorkingDirectory=$1#" systemd-units/mcserv.service

echo "Successfully set server path to $1"
