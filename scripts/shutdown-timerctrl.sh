#!/bin/bash

TIMER_UNIT="mcserv-stop.timer"

num_players=0
changed=0
timer_running=0

tail -n0 -F server.log | while read; do

    last_line="$(tail -n1 server.log)"

    if echo "$last_line" | grep -q "joined the game"; then
        num_players=$((num_players + 1))
        
        if [[ $timer_running == 1 ]]; then
            systemctl stop "$TIMER_UNIT"
            echo "Stopped kill timer"
            timer_running=0
        fi

    elif echo "$last_line" | grep -q "left the game"; then
        num_players=$((num_players - 1))
        
        if [[ $num_players == 0 ]] && [[ $timer_running == 0 ]]; then
            systemctl restart "$TIMER_UNIT"
            echo "Started kill timer"
            timer_running=1
        fi
    fi
done
