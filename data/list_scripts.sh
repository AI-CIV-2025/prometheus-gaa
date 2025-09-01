#!/bin/bash
# Lists all shell scripts (.sh) within the ./data directory.

echo "--- Generated Shell Scripts ---"
echo "Listing .sh files in: $(pwd)/data"
echo ""
find ./data -name "*.sh"
