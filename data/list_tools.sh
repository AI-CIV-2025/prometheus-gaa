#!/bin/bash
# Lists all placeholder scripts within the ./data/tools directory.

echo "--- Generated Placeholder Tools ---"
echo "Listing .sh files in: $(pwd)/data/tools"
echo ""
find ./data/tools -name "*.sh"
