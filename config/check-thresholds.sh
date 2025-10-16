#!/bin/bash
RESULT_FILE=$1
THRESHOLD_P95=500
THRESHOLD_ERROR=1

# Calcula P95 y error rate desde el archivo JTL
P95=$(awk -F, 'NR>1 {print $2}' "$RESULT_FILE" | sort -n | awk '{
  a[NR]=$1
}
END {
  if (NR>0) {
    print a[int(NR*0.95)]
  } else {
    print 0
  }
}')
ERROR_RATE=$(awk -F, 'NR>1 {if ($4 != 200) err++} END {print (err/NR)*100}' "$RESULT_FILE")

echo "P95 response time: $P95 ms"
echo "Error rate: $ERROR_RATE %"

if (( $(echo "$P95 > $THRESHOLD_P95" | bc -l) )) || (( $(echo "$ERROR_RATE > $THRESHOLD_ERROR" | bc -l) )); then
  echo "❌ Thresholds exceeded! Pipeline failed."
  exit 1
else
  echo "✅ Performance within limits."
fi

