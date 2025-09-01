#!/bin/bash
# Fetch data from CoinGecko API for Bitcoin (BTC) and Ethereum (ETH)
# and store it in JSON files.
# Check if jq is installed, if not, try to install it
if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Please install it."
  exit 1
fi

# Set the current date for filename
CURRENT_DATE=$(date +%Y%m%d)

# Define the API endpoint and currencies
API_URL="https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum&order=market_cap_desc&per_page=100&page=1&sparkline=false"

# Fetch data and store in a JSON file
curl -s "$API_URL" -o ./data/btc_eth_data_${CURRENT_DATE}.json

echo "Data fetched and saved to ./data/btc_eth_data_${CURRENT_DATE}.json"
