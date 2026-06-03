#!/bin/sh

# -----------------------------
#  Basic counters
# -----------------------------
COUNT_OK=0
COUNT_TIMEOUT=0
SUM=0
MIN=""
MAX=""

# -----------------------------
#  Histogram buckets
#  (same as in ish-scripts)
# -----------------------------
# 1: 0–25
# 2: 26–49
# 3: 50–99
# 4: 100–199
# 5: 200–399
# 6: 400–799
# 7: 800–1599
# 8: 1600–3199
# 9: 3200–6399
# 10: timeout
BUCKETS="0 0 0 0 0 0 0 0 0 0"

# -----------------------------
#  Add one sample
# -----------------------------
stats_add() {
    VAL="$1"

    # Determine bucket index
    case "$VAL" in
        ''|*[!0-9]*)
            IDX=10 ;;  # timeout
        *)
            if   [ "$VAL" -le 25 ]; then IDX=1
            elif [ "$VAL" -le 49 ]; then IDX=2
            elif [ "$VAL" -le 99 ]; then IDX=3
            elif [ "$VAL" -le 199 ]; then IDX=4
            elif [ "$VAL" -le 399 ]; then IDX=5
            elif [ "$VAL" -le 799 ]; then IDX=6
            elif [ "$VAL" -le 1599 ]; then IDX=7
            elif [ "$VAL" -le 3199 ]; then IDX=8
            elif [ "$VAL" -le 6399 ]; then IDX=9
            else IDX=10
            fi
            ;;
    esac

    # Update OK/timeout counters
    if [ "$IDX" -eq 10 ]; then
        COUNT_TIMEOUT=$((COUNT_TIMEOUT + 1))
    else
        COUNT_OK=$((COUNT_OK + 1))
        SUM=$((SUM + VAL))

        [ -z "$MIN" ] || [ "$VAL" -lt "$MIN" ] && MIN="$VAL"
        [ -z "$MAX" ] || [ "$VAL" -gt "$MAX" ] && MAX="$VAL"
    fi

    # Update bucket count
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

# -----------------------------
#  Print histogram
# -----------------------------
stats_print_histogram() {
    echo ""
    echo "Latency histogram (ms)"

    LABELS="0-25 26-49 50-99 100-199 200-399 400-799 800-1599 1600-3199 3200-6399 timeout"
    MAX_BUCKET=$(echo "$BUCKETS" | tr ' ' '\n' | sort -nr | head -1)

    I=1
    for L in $LABELS; do
        COUNT=$(echo "$BUCKETS" | cut -d' ' -f$I)

        if [ "$MAX_BUCKET" -gt 0 ]; then
            BAR_LEN=$((COUNT * 30 / MAX_BUCKET))
        else
            BAR_LEN=0
        fi

        BAR=$(printf "%${BAR_LEN}s" | tr ' ' '#')

        printf "%-12s | %s\n" "$L" "$BAR"

        I=$((I+1))
    done
}

# -----------------------------
#  Print final statistics
# -----------------------------
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
