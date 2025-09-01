#!/bin/bash

# Script to document AI-generated code samples and store them in the knowledge base.

if [ -z "$1" ]; then
  echo "Usage: $0 <code_file_path> <description>"
  exit 1
fi

CODE_FILE="$1"
DESCRIPTION="$2"

if [ ! -f "$CODE_FILE" ]; then
  echo "Error: Code file '$CODE_FILE' not found."
  exit 1
fi

# Extract filename without path
FILENAME=$(basename "$CODE_FILE")

# Create a unique identifier for the documentation entry
DOC_ID=$(date +%Y%m%d_%H%M%S)_$(echo "$FILENAME" | sed 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]')

# Define the output directory for documentation
OUTPUT_DIR="./data/knowledge_base/ai_collaboration/code_samples"

# Create the documentation file
cat << EOF > "$OUTPUT_DIR/${DOC_ID}_doc.md"
# Code Sample Documentation: $FILENAME

## Description
$DESCRIPTION

## Code Snippet
\`\`\`$(echo "$FILENAME" | rev | cut -d. -f1 | rev)
$(cat "$CODE_FILE")
\`\`\`

## Associated Notes
- This code was generated as part of a collaboration to [mention the context].
- Key features: [list key features]
- Potential improvements: [list potential improvements]

## Generated On
$(date +'%Y-%m-%d %H:%M:%S')
