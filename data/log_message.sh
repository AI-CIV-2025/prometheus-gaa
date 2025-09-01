#!/bin/bash
MESSAGE="$1"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
echo "[$TIMESTAMP] - $MESSAGE" >> ./data/system.log
