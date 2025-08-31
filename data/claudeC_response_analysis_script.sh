#!/bin/bash

RESPONSE_FILE="./data/claudeC_simulated_architecture_response.md"
OUTPUT_FILE="./data/claudeC_architecture_analysis_report.md"

echo "# Claude Code Architecture Response Analysis" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "## Analysis Date" >> "$OUTPUT_FILE"
date >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Overall Structure and Sections Identified" >> "$OUTPUT_FILE"
grep -E "^## " "$RESPONSE_FILE" | sed 's/^## /- /' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Key Technologies Mentioned (Top 10)" >> "$OUTPUT_FILE"
grep -oE '\b(AWS|Azure|GCP|Kubernetes|Docker|Kafka|Spark|Flink|TensorFlow|PyTorch|React|Vue.js|FastAPI|Spring Boot|Node.js|Python|Java|PostgreSQL|MongoDB|S3|Snowflake|Prometheus|Grafana|ELK|Datadog|Jenkins|GitLab CI|GitHub Actions|Keycloak|Auth0|OAuth2|OpenID Connect)\b' "$RESPONSE_FILE" | sort | uniq -c | sort -nr | head -10 | awk '{print "- " $2 " (" $1 " mentions)"}' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Security Considerations Summary" >> "$OUTPUT_FILE"
grep -A 5 "Security Considerations" "$RESPONSE_FILE" | tail -n +2 | grep -vE "^--|^$" | sed 's/^- /- /' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Scalability & High Availability Highlights" >> "$OUTPUT_FILE"
grep -A 5 "Scalability and High Availability" "$RESPONSE_FILE" | tail -n +2 | grep -vE "^--|^$" | sed 's/^- /- /' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Next Steps/Follow-up Questions from Claude Code" >> "$OUTPUT_FILE"
grep -A 5 "Next Steps / Follow-up Questions" "$RESPONSE_FILE" | tail -n +2 | grep -vE "^--|^$" | sed 's/^- /- /' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

echo "## Raw Response Preview" >> "$OUTPUT_FILE"
echo "\`\`\`markdown" >> "$OUTPUT_FILE"
head -n 20 "$RESPONSE_FILE" >> "$OUTPUT_FILE"
echo "..." >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
