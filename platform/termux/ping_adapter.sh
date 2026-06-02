#!/bin/sh

run_ping_once() {
    TARGET="$1"
    PAYLOAD="$2"
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
        *"Destination Host Unreachable"*)
            echo "dest_unreachable"
            ;;
        *"Network is unreachable"*)
            echo "network_unreachable"
            ;;
        *)
            echo "timeout"
            ;;
    esac
}
