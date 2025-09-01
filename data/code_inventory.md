# GAA System Code Inventory

This document inventories the code files within the GAA system's execution path.

## File Listing
The following files are present in the execution environment:

$(ls -R ./data | sed 's/^/  /')

## File Types and Counts
$(find ./data -type f | sed 's/.*\.//' | sort | uniq -c | awk '{print "- " $2 ": " $1}')

## Recent Modifications
$(ls -lt ./data | head -n 10 | sed 's/^/  /')
