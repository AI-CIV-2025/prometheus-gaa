#!/bin/bash
echo "=== GAA System Documentation Catalog ==="
echo "Generated on: $(date)"
echo ""
echo "--- Markdown Files ---"
find . -maxdepth 1 -name "*.md" -type f -print0 | xargs -0 ls -l --time-style=long-iso
echo ""
echo "--- Shell Scripts ---"
find . -maxdepth 1 -name "*.sh" -type f -executable -print0 | xargs -0 ls -l --time-style=long-iso
echo ""
echo "--- Configuration Files ---"
find . -maxdepth 1 -name "*.json" -type f -print0 | xargs -0 ls -l --time-style=long-iso
echo ""
echo "--- Other Text Files ---"
find . -maxdepth 1 ! -name "*.md" ! -name "*.sh" ! -name "*.json" -type f -print0 | xargs -0 ls -l --time-style=long-iso
