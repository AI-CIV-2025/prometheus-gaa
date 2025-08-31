#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: ./data/generate_claude_request.sh <request_name>"
  exit 1
fi

REQUEST_NAME=$(echo "$1" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
OUTPUT_FILE="./data/claude_request_${REQUEST_NAME}.md"

cat << EOT_REQUEST > "$OUTPUT_FILE"
# Request for ClaudeC: ${1}

## Mission
Clearly state the primary goal of this request. What do you want ClaudeC to achieve?

## Core Requirements
List the essential functionalities, features, or components ClaudeC must provide.
1.  Requirement A
2.  Requirement B

## Architecture (Optional)
Suggest specific architectural patterns, communication methods, or design principles.
-   Example: Microservices, Monolith, Serverless
-   Example: RESTful APIs, Message Queues

## Technology Stack (Suggestions)
Propose preferred programming languages, frameworks, databases, or tools.
-   Backend: Python, Node.js, Java, Go
-   Frontend: React, Vue, Angular
-   Database: PostgreSQL, MongoDB, Redis
-   Cloud: AWS, Azure, GCP

## Key Features / Components
Detail specific functionalities expected within the system or codebase.
-   Feature 1: Description
-   Feature 2: Description

## Deliverables
Specify the exact outputs you expect from ClaudeC.
1.  Architecture Diagram (text-based or conceptual description)
2.  API Specifications (e.g., OpenAPI/Swagger)
3.  Core Codebase (multi-file, demonstrating key features)
4.  Database Schemas (SQL DDL or NoSQL JSON examples)
5.  Documentation (README, setup instructions)

## Constraints & Considerations
Mention any limitations, non-functional requirements, or specific areas of focus.
-   Performance, Security, Scalability
-   Integration with existing systems
-   Error handling, logging, testing
EOT_REQUEST

echo "Generated ClaudeC request template: $OUTPUT_FILE"
