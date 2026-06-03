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

    LABELS="0-19 20-39 40-59 60-79 80-119 120-199 200-399 400-799 800-1599 1600-2999 timeout"
    DESCR="výborné dobré priemerné slabé veľmi_slabé 3G_typické 3G_slabé EDGE extrémne zlé timeout"
    COLORS="$C_GREEN $C_GREEN $C_YELLOW $C_YELLOW $C_RED $C_RED $C_RED $C_RED $C_RED $C_RED $C_GRAY"

    MAX_BUCKET=$(echo "$BUCKETS" | tr ' ' '\n' | sort -nr | head -1)

    I=1
    for L in $LABELS; do
        COUNT=$(echo "$BUCKETS" | cut -d' ' -f$I)
        COLOR=$(echo "$COLORS" | cut -d' ' -f$I)
        TEXT=$(echo "$DESCR" | cut -d' ' -f$I | tr '_' ' ')

        if [ "$MAX_BUCKET" -gt 0 ]; then
            BAR_LEN=$((COUNT * 20 / MAX_BUCKET))
        else
            BAR_LEN=0
        fi

        BAR=$(printf "%${BAR_LEN}s" | tr ' ' '#')

        printf "%s%-8s%s | %s%-20s%s | %s\n" \
            "$COLOR" "$L" "$C_RESET" \
            "$COLOR" "$BAR" "$C_RESET" \
            "$TEXT"

        I=$((I+1))
    done
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
