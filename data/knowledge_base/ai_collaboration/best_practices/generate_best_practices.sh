#!/bin/bash

# Script to generate a best practices document based on key lessons learned.

if [ -z "$1" ]; then
  echo "Usage: $0 <best_practice_title> <lesson_learned_file>"
  exit 1
fi

BP_TITLE="$1"
LESSON_FILE="$2"

if [ ! -f "$LESSON_FILE" ]; then
  echo "Error: Lesson learned file '$LESSON_FILE' not found."
  exit 1
fi

# Define the output directory for best practices
OUTPUT_DIR="./data/knowledge_base/ai_collaboration/best_practices"

# Create a unique identifier for the best practice entry
BP_ID=$(date +%Y%m%d_%H%M%S)_$(echo "$BP_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')

# Create the best practice documentation file
cat << EOF > "$OUTPUT_DIR/${BP_ID}_bp.md"
# Best Practice: $BP_TITLE

## Rationale / Origin
This best practice is derived from lessons learned during AI-AI collaboration, specifically related to [mention the context or problem].

## Source Lesson Learned Document
[Reference to: $LESSON_FILE]

## Best Practice Description
**Goal:** [Clearly state the goal of this best practice]

**Actionable Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Important Considerations
- [Consideration 1]
- [Consideration 2]

## Verification
- How to verify this best practice is being followed: [Verification method]

## Documented On
$(date +'%Y-%m-%d %H:%M:%S')
