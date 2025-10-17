#!/bin/bash
set -e

RESULT_FILE=$1
THRESHOLD_P95=500
THRESHOLD_ERROR=1.0

if [ ! -f "$RESULT_FILE" ]; then
    echo "❌ Result file not found"
    exit 1
fi

# Calcular P95
P95=$(awk -F, 'NR>1 {print $2}' "$RESULT_FILE" | sort -n | awk '{a[NR]=$1} END {print a[int(NR*0.95)]}')

# Calcular error rate
TOTAL=$(awk -F, 'NR>1' "$RESULT_FILE" | wc -l)
ERRORS=$(awk -F, 'NR>1 {if ($4 !~ /^2[0-9][0-9]$/) print}' "$RESULT_FILE" | wc -l)
ERROR_RATE=$(echo "scale=2; ($ERRORS / $TOTAL) * 100" | bc)

echo "================================"
echo "Performance Test Results"
echo "================================"
echo "P95 Response Time: ${P95} ms (threshold: ≤${THRESHOLD_P95} ms)"
echo "Error Rate: ${ERROR_RATE}% (threshold: ≤${THRESHOLD_ERROR}%)"
echo "Total Requests: $TOTAL"
echo "Failed Requests: $ERRORS"
echo "================================"

FAILED=0

if [ "$P95" -gt "$THRESHOLD_P95" ]; then
    echo "❌ FAILED: P95 exceeds threshold"
    FAILED=1
fi

ERROR_CHECK=$(echo "$ERROR_RATE > $THRESHOLD_ERROR" | bc -l)
if [ "$ERROR_CHECK" -eq 1 ]; then
    echo "❌ FAILED: Error rate exceeds threshold"
    FAILED=1
fi

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "🚨 PERFORMANCE TEST FAILED"
    exit 1
else
    echo ""
    echo "✅ PERFORMANCE TEST PASSED"
    exit 0
fi

