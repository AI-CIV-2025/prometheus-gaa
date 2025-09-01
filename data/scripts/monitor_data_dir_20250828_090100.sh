 #!/bin/bash

# This script is designed to monitor the specified data directory,
# providing essential insights into its contents, structure, and disk usage.
# It helps in understanding the growth and composition of generated artifacts.

_DATA_DIR="${EXECUTION_PATH:-./data}"

echo "Monitoring Report for Data Directory: $_DATA_DIR"
echo "Generated on: $(date)"
echo "---------------------------------------------------"

echo "1. Directory Contents Summary:"
echo "   - Total items (files + directories): $(ls -A "$_DATA_DIR" 2>/dev/null | wc -l)"
echo "   - Number of subdirectories: $(find "$_DATA_DIR" -maxdepth 1 -type d -not -name '.*' | wc -l)"
echo "   - Number of individual files: $(find "$_DATA_DIR" -maxdepth 1 -type f | wc -l)"
echo ""

echo "2. File Type Breakdown (Top 5 extensions by count):"
# This command finds all files, extracts their extensions, counts them, and lists the top 5.
find "$_DATA_DIR" -type f -name '*.*' -print0 | xargs -0 -I {} bash -c 'echo "${##*.}"' | sort | uniq -c | sort -nr | head -5 | awk '{print "   - "$2": "$1" files"}'
echo ""

echo "3. Disk Usage of the Data Directory:"
# Reports the human-readable disk usage of the specified directory.
du -sh "$_DATA_DIR"
echo ""

echo "4. Recently Modified Files (Last 5, excluding directories):"
# Lists the 5 most recently modified files in the data directory.
ls -lt "$_DATA_DIR" | grep -v '^d' | head -n 6
echo "---------------------------------------------------"
