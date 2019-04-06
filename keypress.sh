#!/bin/bash
declare -A remaps=([mc]="^Minecraft [0-9.]+$")
declare -A mc=([XF86Reload]="F3")

if [[ "$2" ]]; then
    arr="$1[$2]"
    if [[ "${!arr}" ]]; then
        if [[ "$3" = "KeyPress" ]]; then
            echo "keydown ${!arr} for $1 ($2 $3)"
            xdotool keydown "${!arr}"
        else
            echo "keyup ${!arr} for $1 ($2 $3)"
            xdotool keyup "${!arr}"
        fi
    fi
else
    while :; do
        windowid="$(xdotool getactivewindow)"
        windowname="$(xdotool getwindowname $windowid)"
        for K in "${!remaps[@]}"; do
            reg="${remaps[$K]}"
            if [[ $windowname =~ $reg ]]; then
                echo "$windowname ($windowid) matched $K"
                xev -id "$windowid" -event "keyboard" | awk -v cmd="$0 $K" -F'[ )]+' '/^Key(Press|Release)/ {var1=$1 a[NR+2] } NR in a {system(cmd" "$8" "var1)}' &
                RUNNING_PID=$!
                while [[ "$windowid" = $(xdotool getactivewindow) ]]; do
                    sleep 0.2
                done
                kill ${RUNNING_PID}
                break
            fi
            #statements
        done
        sleep 0.2
        echo "looking for diff window"
    done
fi