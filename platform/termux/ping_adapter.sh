#!/bin/sh

run_ping_once() {
    TARGET="$1"
    PAYLOAD="$2"

    # iSH (iputils) podporuje -s
    # Termux (inetutils) podporuje -s, ale nie -W ani -O
    # Preto používame len prepínače, ktoré fungujú všade

    ping -c 1 -s "$PAYLOAD" "$TARGET" 2>&1
}

classify_ping_error() {
    RAW="$1"

    case "$RAW" in
        *"unknown host"*)
            echo "unknown_host"
            ;;
        *"Name or service not known"*)
            echo "name_not_known"
            ;;
        *"Temporary failure in name resolution"*)
            echo "dns_temp_fail"
            ;;
        *"Destination Host Unreachable"*)
            echo "dest_unreachable"
            ;;
        *"Network is unreachable"*)
            echo "network_unreachable"
            ;;
        *"No route to host"*)
            echo "no_route"
            ;;
        *)
            echo "timeout"
            ;;
    esac
}
