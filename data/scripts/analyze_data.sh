#!/bin/bash
# Analyze the CSV data to generate insights such as average price,
# maximum price, and minimum price.
# Find the most recent CSV data file
LATEST_CSV=$(ls -t ./data/btc_eth_data_*.csv | head -n 1)

if [ -z "$LATEST_CSV" ]; then
  echo "No CSV data file found."
  exit 1
fi

# Calculate average price
AVERAGE_PRICE=$(awk -F',' '{sum += $4} END {print sum/NR}' "$LATEST_CSV")

# Find maximum price
MAX_PRICE=$(sort -t',' -k4 -n "$LATEST_CSV" | tail -n 1 | awk -F',' '{print $4}')

# Find minimum price
MIN_PRICE=$(sort -t',' -k4 -n "$LATEST_CSV" | head -n 1 | awk -F',' '{print $4}')

# Generate insights report
cat << EOF > ./data/insights.txt
Cryptocurrency Data Insights
=============================
File: $LATEST_CSV
Average Price: $AVERAGE_PRICE
Maximum Price: $MAX_PRICE
Minimum Price: $MIN_PRICE
