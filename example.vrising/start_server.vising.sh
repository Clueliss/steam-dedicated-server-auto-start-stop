#!/bin/bash

wait_exit() {
    wait $server_pid
    server_exit_code=$?

    wineserver -k

    kill $xvfb_pid
    wait $xbfb_pid

    exit $server_exit_code
}

terminate() {
    kill $server_pid
    wait_exit
}


Xvfb :0 -screen 0 1024x768x16 &
xvfb_pid=$!

DISPLAY=:0.0 wine VRisingServer.exe -address 0.0.0.0 -persistentDataPath ./save-data -serverName "VRisingServer" &
server_pid=$!

trap terminate SIGTERM

wait_exit
