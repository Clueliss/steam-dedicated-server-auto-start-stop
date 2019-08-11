#!/bin/sh

firewall-cmd --remove-forward-port=port=25565:proto=tcp:toport=25555
firewall-cmd --remove-forward-port=port=25565:proto=udp:toport=25555

systemctl stop mcserv-stoptimerctrl.service
