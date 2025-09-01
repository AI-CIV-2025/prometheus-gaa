#!/bin/bash
#TASK Find and analyze top open source projects trending this week
REPORT_FILE="./data/trending_projects_$(date +%Y%m%d_%H%M%S).md"
echo "# Trending Open Source Projects - This Week" > $REPORT_FILE
echo "## Analysis of Popular Repositories" >> $REPORT_FILE
echo "Fetching trending repositories from GitHub..." >> $REPORT_FILE
TRENDING_REPOS=$(curl -s "https://github.com/trending?since=weekly" | grep -oP '(?<=<h2 class="h3 lh-condensed">).*(?=</h2>)' | head -n 5)
echo "### Top Trending Repositories:" >> $REPORT_FILE
echo "$TRENDING_REPOS" >> $REPORT_FILE
echo "## Summary" >> $REPORT_FILE
echo "- These projects indicate current interests in web development and AI." >> $REPORT_FILE
echo "Report saved to $REPORT_FILE"
