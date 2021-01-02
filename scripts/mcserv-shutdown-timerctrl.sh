#!/bin/bash

start_timer() {
    systemctl restart mcserv-stop.timer
}

stop_timer() {
    systemctl stop mcserv-stop.timer
}

players_online=0

start_timer
timer_running=true


journalctl --unit=mcserv.service --follow --since "0 sec ago" | while read line; do
    if echo "$line" | grep -q "joined the game"; then
        players_online=$(($players_online + 1))

        if [[ $timer_running == true ]]; then
            stop_timer
            timer_running=false

            echo "[Info] Stopped kill timer"
        fi
    
    elif echo "$line" | grep -q "left the game"; then
        players_online=$(($players_online - 1))

        if [[ $players_online == 0 ]] && [[ $timer_running == false ]]; then
            start_timer
            timer_running=true

            echo "[Info] Started kill timer"
        fi
    fi
done
