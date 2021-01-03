#!/bin/bash

set -e

cp scripts/* /usr/local/bin
cp systemd-units/* /etc/systemd/system

echo "Success"
