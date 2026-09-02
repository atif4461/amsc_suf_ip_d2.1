#!/bin/bash
# measure_recv_bandwidth_simple.sh
#
# Post-processes an existing e2sar_perf receiver log. Uses the timestamp
# in each "Stats:" block, e.g.:
#
#   8: [23:41:18.114329] {info} Stats:
#           Total Bytes: 5122332
#           ...
#
# Finds the ACTIVE transfer window (periods where Total Bytes increased
# from the previous block) and computes elapsed time + bandwidth over
# just that window -- not the whole log span.
#
# Usage:
#   ./measure_recv_bandwidth_simple.sh <logfile>

set -uo pipefail

LOGFILE="${1:-}"

if [[ -z "$LOGFILE" || ! -f "$LOGFILE" ]]; then
    echo "Usage: $0 <logfile>"
    echo "ERROR: logfile not given or not found: ${LOGFILE:-<none>}"
    exit 1
fi

echo "Log file: $LOGFILE"
echo ""

# Extract (timestamp_seconds, cumulative_total_bytes, clock_string) for
# every Stats block.
SAMPLES=$(awk '
    match($0, /\[([0-9]{2}):([0-9]{2}):([0-9]{2})\.([0-9]+)\]/, ts) {
        h = ts[1] + 0
        m = ts[2] + 0
        s = ts[3] + 0
        frac = ts[4]
        fracsec = frac / (10 ^ length(frac))
        cur_time = h*3600 + m*60 + s + fracsec
        cur_clock = ts[1] ":" ts[2] ":" ts[3] "." ts[4]
        have_time = 1
        next
    }
    /Total Bytes:/ && have_time {
        n = $0
        gsub(/[^0-9]/, "", n)
        printf "%.6f %s %s\n", cur_time, n, cur_clock
        have_time = 0
        next
    }
' "$LOGFILE")

if [[ -z "$SAMPLES" ]]; then
    echo "ERROR: no timestamped 'Total Bytes:' blocks found in $LOGFILE"
    echo "Expected lines like:  8: [23:41:18.114329] {info} Stats:"
    echo "                              Total Bytes: 5122332"
    exit 1
fi

TOTAL_BLOCKS=$(echo "$SAMPLES" | wc -l)

echo "=================================================================="
echo "RESULT"
echo "=================================================================="

echo "$SAMPLES" | awk -v total_blocks="$TOTAL_BLOCKS" '
{
    ts[NR] = $1
    bytes[NR] = $2
    clock[NR] = $3
}
END {
    n = NR
    if (n < 2) {
        print "ERROR: need at least 2 Stats blocks to compute a rate; only got", n
        exit 1
    }

    active_blocks = 0
    start_idx = 0   # sample BEFORE the first active block (baseline)
    end_idx = 0      # last active block

    for (i = 2; i <= n; i++) {
        if (bytes[i] > bytes[i-1]) {
            active_blocks++
            if (start_idx == 0) {
                start_idx = i - 1
            }
            end_idx = i
        }
    }

    if (start_idx == 0 || end_idx == 0) {
        print "ERROR: Total Bytes never increased across samples -- no active transfer window found."
        exit 1
    }

    t_start = ts[start_idx]
    t_end   = ts[end_idx]
    duration = t_end - t_start
    if (duration < 0) duration += 86400   # midnight wraparound guard

    b_start = bytes[start_idx]
    b_end   = bytes[end_idx]
    delta_bytes = b_end - b_start

    printf "Total Stats blocks in log:        %d\n", total_blocks
    printf "Active blocks (bytes increased):  %d\n", active_blocks
    printf "Window start (baseline, #%d): t=%s  bytes=%d\n", start_idx, clock[start_idx], b_start
    printf "Window end   (last active,#%d): t=%s  bytes=%d\n", end_idx, clock[end_idx], b_end
    printf "Active transfer window:  %.6f s\n", duration
    printf "Bytes transferred in window: %d\n", delta_bytes

    if (duration <= 0) {
        print "ERROR: non-positive duration; cannot compute rate."
        exit 1
    }

    gbps = (delta_bytes * 8) / (duration * 1e9)
    printf "\nMeasured receive bandwidth (active window): %.4f Gbps\n", gbps
}
'
