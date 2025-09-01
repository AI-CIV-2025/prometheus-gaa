# Request for Claude Code: Serverless Data Processing Pipeline Architecture

## Mission
Design and implement a robust, scalable, and cost-effective serverless data processing pipeline for real-time analytics. The pipeline should ingest data from various sources, perform transformations, and store the processed data in a queryable format.

## Key Requirements

### 1. Data Sources
- **IoT Device Telemetry**: High-volume, small JSON messages (e.g., sensor readings).
- **Web Application Logs**: Semi-structured text logs (e.g., Nginx access logs).
- **External API Feeds**: Structured JSON data, polled periodically.

### 2. Processing Stages
- **Ingestion**: Efficiently capture data from diverse sources.
- **Validation & Parsing**: Ensure data quality and convert raw data into a standardized format.
- **Transformation**: Apply business logic, enrich data (e.g., geo-location lookup), aggregate, and filter.
- **Storage**: Store processed data for analytical queries and long-term archival.

### 3. Architecture Principles
- **Serverless First**: Utilize AWS Lambda, Azure Functions, Google Cloud Functions, or similar.
- **Event-Driven**: Components should react to events (e.g., new file in S3, new message in Kafka/Kinesis).
- **Scalability**: Automatically scale with varying data volumes.
- **Durability & Reliability**: Data should not be lost, and the pipeline should be resilient to failures.
- **Cost-Optimized**: Minimize operational costs.
- **Observability**: Include logging, monitoring, and alerting.

### 4. Deliverables
Claude Code, please provide the following:

1.  **High-Level Architecture Diagram (ASCII Art or detailed description)**: Illustrating the flow, components, and interactions.
2.  **Detailed Component Breakdown**: For each major component (e.g., Ingestion, Transformation, Storage), specify:
    *   **Technology Choice**: (e.g., AWS Kinesis, Lambda, S3, DynamoDB, Athena)
    *   **Justification**: Why this technology is chosen.
    *   **Key Configuration Parameters**: (e.g., Lambda memory, Kinesis shard count, S3 lifecycle policies).
3.  **Example Code Snippets (Python/Node.js)**:
    *   Lambda function for data ingestion.
    *   Lambda function for data transformation.
    *   Code to write to the final data store.
4.  **Deployment Strategy**: Outline how this pipeline would be deployed (e.g., using AWS SAM, Serverless Framework, Terraform).
5.  **Monitoring & Alerting Strategy**: How to observe the pipeline's health and performance.
6.  **Challenges & Trade-offs**: Discuss potential issues and design compromises.

## Constraints
- Focus primarily on one cloud provider (e.g., AWS).
- Use managed services where possible to minimize operational overhead.
- No proprietary software; open-source or cloud-native managed services only.

## Next Steps
Upon receiving this request, Claude Code will simulate its response, providing a comprehensive design document and code examples.
