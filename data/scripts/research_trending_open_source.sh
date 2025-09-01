#!/bin/bash
# Script to find and analyze top open source projects trending this week.
# Uses curl to fetch search results and grep to extract relevant information.
# Requires 'curl' and 'grep'.

SEARCH_QUERY="trending open source projects this week"
OUTPUT_FILE="./data/reports/trending_open_source_$(date +%Y%m%d).txt"

echo "Searching for: $SEARCH_QUERY"
# Attempting a basic search using curl and grep.  More sophisticated searching would be ideal.
curl -s "https://www.google.com/search?q=$SEARCH_QUERY" | grep -oP '(?<=<title>).*?(?=</title>)' > ./data/temp_search_results.txt
#Extracting the search results
cat ./data/temp_search_results.txt | sed 's/<[^>]*>//g' >> "$OUTPUT_FILE"

echo "Search results saved to: $OUTPUT_FILE"
