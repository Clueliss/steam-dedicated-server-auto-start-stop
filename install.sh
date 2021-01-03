#!/bin/bash

set -e

install scripts/* /usr/local/bin
install systemd-units/* /etc/systemd/system

echo "Success"
