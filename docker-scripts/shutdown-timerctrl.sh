#!/bin/bash

start_timer() {
    systemctl restart mcserv-stop.timer
}

stop_timer() {
    systemctl stop mcserv-stop.timer
}

init_num_players() {
    declare -i num_joins=$(docker logs minecraft | grep "joined the game" | wc -l)
    declare -i num_leaves=$(docker logs minecraft | grep "left the game" | wc -l)

    echo $(($num_joins - $num_leaves))
}

players_online=$(init_num_players)

if [[ $players_online == 0 ]]; then
    start_timer
    timer_running=true

    echo "[Info] Timer Running"
else
   stop_timer
   timer_running=false

   echo "[Info] Timer Stopped"
fi


docker logs minecraft --follow --since 0s | while read line; do
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
