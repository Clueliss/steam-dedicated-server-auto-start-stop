#!/bin/bash

if mkdir /opt/mcserv/scripts; then
    cp -r scripts /opt/mcserv/scripts
    cp systemd-units/* /etc/systemd/system
fi
