#!/bin/sh

COUNT_OK=0
COUNT_TIMEOUT=0
SUM=0
MIN=""
MAX=""

stats_add() {
    VAL="$1"
    if [ "$VAL" = "timeout" ]; then
        COUNT_TIMEOUT=$((COUNT_TIMEOUT + 1))
        return
    fi

    COUNT_OK=$((COUNT_OK + 1))
    SUM=$((SUM + VAL))

    [ -z "$MIN" ] || [ "$VAL" -lt "$MIN" ] && MIN="$VAL"
    [ -z "$MAX" ] || [ "$VAL" -gt "$MAX" ] && MAX="$VAL"
}

stats_print() {
    echo "---- stats ----"
    echo "OK:       $COUNT_OK"
    echo "Timeouts: $COUNT_TIMEOUT"
    if [ "$COUNT_OK" -gt 0 ]; then
        AVG=$((SUM / COUNT_OK))
        echo "Min:      ${MIN} ms"
        echo "Max:      ${MAX} ms"
        echo "Avg:      ${AVG} ms"
    fi
}
