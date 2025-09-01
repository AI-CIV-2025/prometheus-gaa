#!/bin/bash
#TASK Search the web for latest AI developments and create a report
# Search for current AI trends using a combination of search terms
search_terms=("latest AI developments" "trending AI research" "new AI models" "AI applications 2025")

# Create a temporary file to store search results
temp_file="./data/ai_trends_search_results.txt"

# Loop through search terms and append results to the temp file
for term in "${search_terms[@]}"; do
    echo "Searching for: $term"
    curl -s "https://www.google.com/search?q=$term" | grep -Eo 'https?://[^" ]+' >> "$temp_file"
    sleep 2 # Be polite and avoid rate limiting
done

# Clean up the results (remove duplicates and sort)
sort -u "$temp_file" -o "$temp_file"

# Extract relevant information from the search results (example: titles and descriptions)
echo "Extracting titles and descriptions..."
cat "$temp_file" | while read -r url; do
    echo "Fetching: $url"
    curl -s "$url" | grep -Eo '<title>.*?</title>' | sed 's/<[^>]*>//g' >> ./data/ai_trends_titles.txt
    curl -s "$url" | grep -Eo '<meta name="description" content=".*?>' | sed 's/<[^>]*>//g' | sed 's/content=//g' >> ./data/ai_trends_descriptions.txt"
    sleep 2 # Be polite and avoid rate limiting
done

# Create a report summarizing the findings
echo "Generating AI trends report..."
cat << EOF > ./data/ai_trends_report.md
# AI Trends Report $(date +%Y-%m-%d)

## Summary
This report summarizes the latest AI trends based on a web search conducted on $(date +%Y-%m-%d).

## Search Terms Used
$(printf "- %s\n" "${search_terms[@]}")

## Search Results
$(wc -l < "$temp_file") URLs found.

## Titles
$(cat ./data/ai_trends_titles.txt)

## Descriptions
$(cat ./data/ai_trends_descriptions.txt)

## Analysis (To be completed manually)
Further analysis is required to categorize and prioritize these trends.

