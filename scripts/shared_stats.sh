#!/bin/sh

COUNT_OK=0
COUNT_TIMEOUT=0
SUM=0
MIN=""
MAX=""

BUCKETS="0 0 0 0 0 0 0 0 0 0 0"

C_RESET=$(printf '\033[0m')
C_GREEN=$(printf '\033[32m')
C_YELLOW=$(printf '\033[33m')
C_RED=$(printf '\033[31m')
C_GRAY=$(printf '\033[90m')

stats_add() {
    VAL="$1"

    case "$VAL" in
        ''|*[!0-9]*)
            IDX=11 ;;
        *)
            if   [ "$VAL" -le 19 ]; then IDX=1
            elif [ "$VAL" -le 39 ]; then IDX=2
            elif [ "$VAL" -le 59 ]; then IDX=3
            elif [ "$VAL" -le 79 ]; then IDX=4
            elif [ "$VAL" -le 119 ]; then IDX=5
            elif [ "$VAL" -le 199 ]; then IDX=6
            elif [ "$VAL" -le 399 ]; then IDX=7
            elif [ "$VAL" -le 799 ]; then IDX=8
            elif [ "$VAL" -le 1599 ]; then IDX=9
            elif [ "$VAL" -le 2999 ]; then IDX=10
            else IDX=11
            fi
            ;;
    esac

    if [ "$IDX" -eq 11 ]; then
        COUNT_TIMEOUT=$((COUNT_TIMEOUT + 1))
    else
        COUNT_OK=$((COUNT_OK + 1))
        SUM=$((SUM + VAL))
        [ -z "$MIN" ] || [ "$VAL" -lt "$MIN" ] && MIN="$VAL"
        [ -z "$MAX" ] || [ "$VAL" -gt "$MAX" ] && MAX="$VAL"
    fi

    OLD=$(echo "$BUCKETS" | cut -d' ' -f$IDX)
    NEW=$((OLD + 1))

    BUCKETS=$(echo "$BUCKETS" | awk -v i=$IDX -v v=$NEW '
        {
            for (n=1; n<=NF; n++) {
                if (n==i) printf "%d ", v;
                else printf "%s ", $n;
            }
        }')
}

stats_print_histogram() {
    echo ""
    echo "Latency histogram (ms)"

    # Labels (pevná šírka 10 znakov)
    L1="0-19     ";   D1="4G výborné";        C1=$C_GREEN
    L2="20-39    ";   D2="4G dobré";          C2=$C_GREEN
    L3="40-59    ";   D3="4G priemerné";      C3=$C_YELLOW
    L4="60-79    ";   D4="4G slabé";          C4=$C_YELLOW
    L5="80-119   ";   D5="4G veľmi slabé";    C5=$C_RED
    L6="120-199  ";   D6="4G zahltené";       C6=$C_RED
    L7="200-399  ";   D7="2G rýchle";         C7=$C_RED
    L8="400-799  ";   D8="2G pomalé";         C8=$C_RED
    L9="800-1599 ";   D9="2G veľmi pomalé";   C9=$C_RED
    L10="1600-2999";  D10="2G extrémne";      C10=$C_RED
    L11="timeout ";   D11="timeout";          C11=$C_GRAY

    MAX_BUCKET=$(echo "$BUCKETS" | tr ' ' '\n' | sort -nr | head -1)

    print_row() {
        LABEL="$1"
        COUNT="$2"
        COLOR="$3"
        DESC="$4"

        if [ "$MAX_BUCKET" -gt 0 ]; then
            BAR_LEN=$((COUNT * 20 / MAX_BUCKET))
        else
            BAR_LEN=0
        fi

        BAR=$(printf "%${BAR_LEN}s" | tr ' ' '#')

        printf "%s%-10s | %-20s | %s%s\n" \
            "$COLOR" "$LABEL" "$BAR" "$DESC" "$C_RESET"
    }

    print_row "$L1"  "$(echo "$BUCKETS" | cut -d' ' -f1)"  "$C1"  "$D1"
    print_row "$L2"  "$(echo "$BUCKETS" | cut -d' ' -f2)"  "$C2"  "$D2"
    print_row "$L3"  "$(echo "$BUCKETS" | cut -d' ' -f3)"  "$C3"  "$D3"
    print_row "$L4"  "$(echo "$BUCKETS" | cut -d' ' -f4)"  "$C4"  "$D4"
    print_row "$L5"  "$(echo "$BUCKETS" | cut -d' ' -f5)"  "$C5"  "$D5"
    print_row "$L6"  "$(echo "$BUCKETS" | cut -d' ' -f6)"  "$C6"  "$D6"
    print_row "$L7"  "$(echo "$BUCKETS" | cut -d' ' -f7)"  "$C7"  "$D7"
    print_row "$L8"  "$(echo "$BUCKETS" | cut -d' ' -f8)"  "$C8"  "$D8"
    print_row "$L9"  "$(echo "$BUCKETS" | cut -d' ' -f9)"  "$C9"  "$D9"
    print_row "$L10" "$(echo "$BUCKETS" | cut -d' ' -f10)" "$C10" "$D10"
    print_row "$L11" "$(echo "$BUCKETS" | cut -d' ' -f11)" "$C11" "$D11"
}


stats_print() {
    echo ""
    echo "----- Statistics -----"
    echo "OK:       $COUNT_OK"
    echo "Timeouts: $COUNT_TIMEOUT"

    if [ "$COUNT_OK" -gt 0 ]; then
        AVG=$((SUM / COUNT_OK))
        echo "Min:      ${MIN} ms"
        echo "Max:      ${MAX} ms"
        echo "Avg:      ${AVG} ms"
    else
        echo "No valid samples."
    fi

    echo "----------------------"

    stats_print_histogram
}
