#!/bin/bash

start_timer() {
    systemctl restart mcserv-stop.timer
}

stop_timer() {
    systemctl stop mcserv-stop.timer
}

init_player_count() {
    declare -i cnt=0

    docker logs minecraft | while read line; do
        if echo $line | grep -q "joined the game"; then
            local cnt=$cnt + 1
        elif echo $line | grep -q "left the game"; then
            local cnt=$cnt - 1
        fi
    done

    echo $cnt
}


declare timer_running=false
declare -i players_online=$(init_player_count)

if [[ players_online == 0 ]]; then
    start_timer
    timer_running=true

    echo "[Info] Started Timer"
fi


docker logs minecraft --follow --since 0s | while read line; do
    if echo "$line" | grep -q "joined the game"; then
        num_players=$num_players + 1

        if [[ $timer_running == true ]]; then
            stop_timer
            timer_running=false

            echo "[Info] Stopped kill timer"
        fi

    elif echo "$line" | grep -q "left the game"; then
        num_players=$num_players - 1

        if [[ $num_players == 0 ]] && [[ $timer_running == false ]]; then
            start_timer
            timer_running=true
            
            echo "[Info] Started kill timer"
        fi
    fi
done
