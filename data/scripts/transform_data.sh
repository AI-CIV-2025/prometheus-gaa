#!/bin/bash
# Convert the JSON data to CSV format for easier analysis.
# Check if jq is installed, if not, try to install it
if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Please install it."
  exit 1
fi

# Find the most recent JSON data file
LATEST_JSON=$(ls -t ./data/btc_eth_data_*.json | head -n 1)

if [ -z "$LATEST_JSON" ]; then
  echo "No JSON data file found."
  exit 1
fi

# Extract the date from the filename
DATE=$(echo "$LATEST_JSON" | sed 's/.\/data\/btc_eth_data_\(.*\)\.json/\1/')

# Convert JSON to CSV using jq
jq -r '.[] | [.id, .symbol, .name, .current_price, .market_cap] | @csv' "$LATEST_JSON" > ./data/btc_eth_data_${DATE}.csv

echo "Data transformed and saved to ./data/btc_eth_data_${DATE}.csv"
