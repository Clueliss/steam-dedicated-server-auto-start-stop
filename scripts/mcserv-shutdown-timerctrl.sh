#!/bin/bash

start_timer() {
    systemctl restart mcserv-stop.timer
}

stop_timer() {
    systemctl stop mcserv-stop.timer
}

init_num_players() {
    declare start_time=$(docker inspect --format='{{.State.StartedAt}}' minecraft)
    declare -i num_joins=$(docker logs --since=$start_time minecraft | grep "joined the game" | wc -l)
    declare -i num_leaves=$(docker logs --since=$start_time minecraft | grep "left the game" | wc -l)

    echo $(($num_joins - $num_leaves))
}

if [[ $(docker inspect --format='{{.State.Running}}' minecraft) == true ]]; then
    players_online=$(init_num_players)
    echo "[Info] Initial state determined: playercount = $players_online"
else
    players_online=0
    echo "[Info] Server not running; nothing to do. Waiting..."
fi

    
if [[ $players_online == 0 ]]; then
    start_timer
    timer_running=true
    
    echo "[Info] starting timer"
else
   stop_timer
   timer_running=false
   
   echo "[Info] stopping timer"
fi


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