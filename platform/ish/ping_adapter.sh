#!/bin/sh

run_ping_once() {
    TARGET="$1"
    PAYLOAD="$2"
    ping -c 1 -s "$PAYLOAD" "$TARGET" 2>&1
}

classify_ping_error() {
    RAW="$1"

    case "$RAW" in
        *"bad address"*)
            echo "bad_address"
            ;;
        *"unknown host"*)
            echo "unknown_host"
            ;;
        *"Host is unreachable"*)
            echo "host_unreachable"
            ;;
        *"Network is unreachable"*)
            echo "network_unreachable"
            ;;
        *"Destination Host Unreachable"*)
            echo "dest_unreachable"
            ;;
        *)
            echo "timeout"
            ;;
    esac
}
