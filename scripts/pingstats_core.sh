#!/bin/sh

. "$BASE_DIR/scripts/shared_stats.sh"   # musí byť prvé!
. "$PING_ADAPTER"                    # nastaví ho wrapper

CONFIG_FILE="./ping.conf"
[ -f "$CONFIG_FILE" ] && . "$CONFIG_FILE"

: "${TARGET:=sme.sk}"
: "${MTU:=1500}"

PAYLOAD=$((MTU - 28))
[ "$PAYLOAD" -lt 0 ] && PAYLOAD=0

LOGFILE="pinglog_$(date +"%Y-%m-%d_%H-%M-%S").txt"

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
RESET="\033[0m"

SEQ=0

finish() {
    echo ""
    stats_print | tee -a "$LOGFILE"
    exit 0
}

trap finish INT

echo "Cisco‑style ping to $TARGET (MTU=$MTU, payload=$PAYLOAD)"
echo "Logging to $LOGFILE"
echo "Press CTRL+C to stop"
echo ""

while true; do
    RAW=$(run_ping_once "$TARGET" "$PAYLOAD")
    TS=$(date +"[%Y-%m-%d %H:%M:%S]")

    LINE=$(echo "$RAW" | grep "bytes from")

    if [ -n "$LINE" ]; then
        printf "${GREEN}!${RESET}"

        echo "$TS seq=$SEQ $LINE" >> "$LOGFILE"

        TIME=$(echo "$LINE" | grep -o "time=[0-9.]*" | cut -d= -f2)
        TIME_INT=${TIME%.*}

        stats_add "$TIME_INT"
        SEQ=$((SEQ + 1))
    else
        REASON=$(classify_ping_error "$RAW")

        case "$REASON" in
            bad_address|unknown_host|name_not_known)
                printf "${MAGENTA}?${RESET}"
                ;;
            host_unreachable|dest_unreachable)
                printf "${YELLOW}U${RESET}"
                ;;
            network_unreachable)
                printf "${BLUE}N${RESET}"
                ;;
            timeout|*)
                printf "${RED}.${RESET}"
                ;;
        esac

        echo "$TS seq=$SEQ $REASON: $RAW" >> "$LOGFILE"
        stats_add "timeout"
        SEQ=$((SEQ + 1))
    fi
done
