# Cryptocurrency Data Pipeline Documentation

## Overview
This data pipeline fetches cryptocurrency data from the CoinGecko API,
transforms it to CSV format, analyzes the data to generate insights,
and creates a simple real-time dashboard (placeholder).

## Components
1. **Data Acquisition:** Fetches data from the CoinGecko API using `curl`.
2. **Data Transformation:** Converts JSON data to CSV format using `jq`.
3. **Data Analysis:** Analyzes the CSV data to generate insights using `awk` and `sort`.
4. **Real-Time Dashboard:** A placeholder for a real-time dashboard that would display the data using WebSockets.

## Scripts
- `fetch_data.sh`: Fetches data from the CoinGecko API.
- `transform_data.sh`: Converts JSON data to CSV format.
- `analyze_data.sh`: Analyzes the CSV data to generate insights.
- `dashboard.sh`: Placeholder for a real-time dashboard.

## Data Files
- `btc_eth_data_[DATE].json`: Raw JSON data from the CoinGecko API.
- `btc_eth_data_[DATE].csv`: Transformed CSV data.
- `insights.txt`: Insights generated from the data analysis.

## Dependencies
- `curl`: For fetching data from the API.
- `jq`: For converting JSON data to CSV format.
- `awk`: For data analysis.
- `sort`: For data analysis.

## Usage
1. Run `fetch_data.sh` to fetch the data.
2. Run `transform_data.sh` to transform the data.
3. Run `analyze_data.sh` to analyze the data and generate insights.
4. Run `dashboard.sh` to view the real-time dashboard (placeholder).
