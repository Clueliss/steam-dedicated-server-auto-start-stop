#!/bin/sh

firewall-cmd --add-forward-port=port=25565:proto=tcp:toport=25555
firewall-cmd --add-forward-port=port=25565:proto=udp:toport=25555

systemctl start mcserv-stoptimerctrl.service
