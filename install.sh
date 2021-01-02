#!/bin/bash

set -e

cp scripts/default/* /usr/bin
cp systemd-units/default/* /etc/systemd/system
cp systemd-units/*.* /etc/systemd/system
chmod +x /usr/bin/mcserv-*
echo "Success"
