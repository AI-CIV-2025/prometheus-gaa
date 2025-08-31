#!/bin/bash

# Script to log significant lessons learned from AI-AI collaboration sessions.

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <lesson_title> <detailed_lesson_description>"
  exit 1
fi

LESSON_TITLE="$1"
LESSON_DESC="$2"

# Define the output directory for lessons learned
OUTPUT_DIR="./data/knowledge_base/ai_collaboration/lessons_learned"

# Create a unique identifier for the lesson learned entry
LESSON_ID=$(date +%Y%m%d_%H%M%S)_$(echo "$LESSON_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')

# Create the lesson learned documentation file
cat << EOF > "$OUTPUT_DIR/${LESSON_ID}_lesson.md"
# Lesson Learned: $LESSON_TITLE

## Detailed Description
$LESSON_DESC

## Context
This lesson was learned during the AI-AI collaboration session focused on [mention the context, e.g., 'building a distributed cache system'].

## Impact
- [Describe the impact of this lesson, e.g., 'avoided significant debugging time', 'improved code efficiency']

## Mitigation / Recommendation
- Based on this lesson, we recommend [specific action or change].

## Logged On
$(date +'%Y-%m-%d %H:%M:%S')
