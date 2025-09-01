#!/bin/bash
# Script to research Kubernetes best practices in 2025 and create a report.
# Uses curl to fetch search results and grep to extract relevant information.
# Requires 'curl' and 'grep'.

SEARCH_QUERY="Kubernetes best practices 2025"
OUTPUT_FILE="./data/reports/kubernetes_best_practices_$(date +%Y%m%d).txt"

echo "Searching for: $SEARCH_QUERY"
# Attempting a basic search using curl and grep.  More sophisticated searching would be ideal.
curl -s "https://www.google.com/search?q=$SEARCH_QUERY" | grep -oP '(?<=<title>).*?(?=</title>)' > ./data/temp_search_results.txt
#Extracting the search results
cat ./data/temp_search_results.txt | sed 's/<[^>]*>//g' >> "$OUTPUT_FILE"

echo "Search results saved to: $OUTPUT_FILE"
