# Request for Claude Code: Serverless Real-time Data Processing Pipeline

## Mission
Design and provide a comprehensive implementation plan for a serverless, real-time data processing pipeline. This pipeline should be capable of ingesting data from simulated IoT devices, performing transformations and aggregations, storing the processed data, and exposing an API for analytical queries.

## Core Requirements
1.  **Scalability**: Must be designed for high throughput and low latency, scaling automatically with demand.
2.  **Cost-Effectiveness**: Leverage serverless components to minimize operational overhead and pay-per-use billing.
3.  **Real-time Analytics**: Enable near real-time insights from incoming data streams.
4.  **Observability**: Include considerations for logging, monitoring, and error handling.

## Deliverables Expected from ClaudeC
Please provide the following artifacts, prioritizing clarity, modularity, and best practices:

### 1. System Architecture Design
*   **Architecture Diagram (Markdown/Mermaid syntax)**: A high-level visual representation of all components and data flows.
*   **Component Description**: Detailed explanation of each service used (e.g., AWS Lambda, Kinesis, DynamoDB, API Gateway, S3).

### 2. Core Serverless Function Code (Python)
*   **Data Ingestion Lambda**: Python code to receive and buffer raw IoT data.
*   **Data Processing Lambda**: Python code to transform, filter, and aggregate ingested data.
*   **Analytics API Lambda**: Python code to expose a RESTful API for querying processed data.
*   **Common Utilities/Layers**: Any shared code or helper functions.

### 3. Database Schema Definition
*   **NoSQL Database Schema (JSON/YAML)**: Define the structure for storing processed data (e.g., DynamoDB table definition).

### 4. Infrastructure-as-Code (Terraform/CloudFormation)
*   **Deployment Scripts**: Scripts to provision all necessary AWS resources (Lambda functions, API Gateway, DynamoDB tables, Kinesis streams, IAM roles, etc.).

### 5. Comprehensive Documentation
*   **Setup Guide**: Instructions for setting up the development environment.
*   **Deployment Guide**: Steps to deploy the entire pipeline.
*   **Usage Guide**: How to interact with the API and monitor the pipeline.
*   **Troubleshooting & Best Practices**: Common issues and recommendations.

## Scenario Context
Imagine the IoT devices send JSON payloads like:
\`\`\`json
{
    "device_id": "iot-sensor-001",
    "timestamp": "2025-08-31T10:00:00Z",
    "temperature": 25.5,
    "humidity": 60.2,
    "location": {"lat": 34.0522, "lon": -118.2437}
}
\`\`\`
The processing step should, for example, calculate hourly averages per device and store them.

## Objective
Push the boundaries of AI-AI collaboration by demonstrating ClaudeC's ability to provide a complete, actionable, and well-documented solution to a complex cloud engineering challenge.
