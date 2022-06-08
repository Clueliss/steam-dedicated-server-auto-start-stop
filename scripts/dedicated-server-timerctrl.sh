#!/bin/bash

set -euo pipefail

start_timer() {
    systemctl restart dedicated-server-stop.timer
}

stop_timer() {
    systemctl stop dedicated-server-stop.timer
}

read_log() {
    case "$DDSERV_LOG_SOURCE" in
        journald)
            journalctl --follow --since="0 sec ago" --output=cat --unit=dedicated-server.service
            ;;
        file)
            tail --follow --lines=0 "$DDSERV_LOG_FILE"
            ;;
        *)
            echo "<3> invalid log source $DDSERV_LOG_SOURCE" 1>&2
            exit 1
            ;;
    esac
}

players_online=0

start_timer
timer_running=true

echo "<7> Using join pattern: $DDSERV_JOIN_PATTERN"
echo "<7> Using leave pattern: $DDSERV_LEAVE_PATTERN"

read_log | while read line; do
    if echo "$line" | grep -qE "$DDSERV_JOIN_PATTERN"; then
        players_online=$(($players_online + 1))

        if [[ $timer_running == true ]]; then
            stop_timer
            timer_running=false

            echo "<6> Stopped kill timer"
        fi
    
    elif echo "$line" | grep -qE "$DDSERV_LEAVE_PATTERN"; then
        players_online=$(($players_online - 1))

        if [[ $players_online == 0 ]] && [[ $timer_running == false ]]; then
            start_timer
            timer_running=true

            echo "<6> Started kill timer"
        fi
    fi
done
