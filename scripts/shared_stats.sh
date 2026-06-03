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
#  Histogram buckets (mobile-optimized)
# -----------------------------
# 1: 0–19 ms       → výborné LTE / 5G SA
# 2: 20–39 ms      → dobré LTE / 5G NSA
# 3: 40–59 ms      → priemerné LTE
# 4: 60–79 ms      → slabé LTE
# 5: 80–119 ms     → veľmi slabé LTE / 3G
# 6: 120–199 ms    → 3G typické
# 7: 200–399 ms    → 3G slabé / EDGE rýchle
# 8: 400–799 ms    → EDGE
# 9: 800–1599 ms   → EDGE / extrémne
# 10: 1600–2999 ms → veľmi zlé / satelit
# 11: timeout
BUCKETS="0 0 0 0 0 0 0 0 0 0 0"

# -----------------------------
#  ANSI colors
# -----------------------------
C_RESET="\033[0m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_RED="\033[31m"
C_GRAY="\033[90m"

# -----------------------------
#  Add one sample
# -----------------------------
stats_add() {
    VAL="$1"

    case "$VAL" in
        ''|*[!0-9]*)
            IDX=11 ;;  # timeout
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

# -----------------------------
#  Print histogram
# -----------------------------
stats_print_histogram() {
    echo ""
    echo "Latency histogram (ms)"

    LABELS="0-19 20-39 40-59 60-79 80-119 120-199 200-399 400-799 800-1599 1600-2999 timeout"
    DESCR="výborné_LTE/5G dobré_LTE priemerné_LTE slabé_LTE veľmi_slabé_LTE/3G 3G_typické 3G_slabé/EDGE EDGE extrémne veľmi_zlé/satelit timeout"
    COLORS="$C_GREEN $C_GREEN $C_YELLOW $C_YELLOW $C_RED $C_RED $C_RED $C_RED $C_RED $C_RED $C_GRAY"

    MAX_BUCKET=$(echo "$BUCKETS" | tr ' ' '\n' | sort -nr | head -1)

    I=1
    for L in $LABELS; do
        COUNT=$(echo "$BUCKETS" | cut -d' ' -f$I)
        COLOR=$(echo "$COLORS" | cut -d' ' -f$I)
        TEXT=$(echo "$DESCR" | cut -d' ' -f$I | tr '_' ' ')

        if [ "$MAX_BUCKET" -gt 0 ]; then
            BAR_LEN=$((COUNT * 30 / MAX_BUCKET))
        else
            BAR_LEN=0
        fi

        BAR=$(printf "%${BAR_LEN}s" | tr ' ' '#')

        printf "%-12s | %s%-30s%s | %s\n" "$L" "$COLOR" "$BAR" "$C_RESET" "$TEXT"

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
