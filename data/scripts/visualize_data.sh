#!/bin/bash
# Create a simple ASCII chart
max_price=$(sort -nr ./data/prices.txt | head -n 1)
scale=20 # Height of the chart

echo "Bitcoin Price Chart (Last 30 Days):" > ./data/visualization.txt
while read -r price; do
    bar_length=$((price * scale / max_price))
    bar=$(printf "%${bar_length}s" | tr " " "#")
    echo "$bar" >> ./data/visualization.txt
done < ./data/prices.txt
echo "Chart saved to ./data/visualization.txt"
