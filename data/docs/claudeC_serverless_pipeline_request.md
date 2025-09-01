# Request for Claude Code: Serverless Real-time Data Processing Pipeline with Anomaly Detection

## Project Overview
Design and implement a robust, scalable, and cost-effective serverless data processing pipeline for real-time ingestion, transformation, and anomaly detection of IoT device data. The pipeline should integrate machine learning for identifying unusual patterns in the data stream.

## Core Requirements

### 1. Data Ingestion
-   **Source:** Simulate streaming IoT device data (e.g., sensor readings like temperature, humidity, pressure, device ID, timestamp).
-   **Technology:** AWS Kinesis Data Streams or SQS for reliable, high-throughput ingestion.
-   **Data Format:** JSON.

### 2. Real-time Data Processing & Transformation
-   **Component:** AWS Lambda function.
-   **Functionality:**
    -   Validate incoming data schema.
    -   Enrich data with metadata (e.g., geographical location based on device ID).
    -   Filter out malformed or irrelevant data points.
    -   Aggregate data over small time windows (e.g., 1-minute averages).
-   **Output:** Transformed JSON data.

### 3. Anomaly Detection with Machine Learning
-   **Component:** Integrate with an AWS SageMaker endpoint or a dedicated Lambda function with an embedded lightweight model.
-   **Model:** Assume a pre-trained anomaly detection model (e.g., Isolation Forest, Autoencoder) is available. ClaudeC should provide a conceptual model interface.
-   **Functionality:**
    -   Invoke the ML model with processed data.
    -   Receive anomaly scores or classifications.
    -   Flag anomalous data points.

### 4. Data Storage
-   **Processed Data:** Store all processed (and non-anomalous) data in a cost-effective, queryable database (e.g., AWS DynamoDB for fast access, or S3 for long-term archival).
-   **Anomalies:** Store flagged anomalous data points separately for further investigation (e.g., a dedicated DynamoDB table or an S3 bucket with alerts).

### 5. API for Data Querying
-   **Component:** AWS API Gateway + Lambda function.
-   **Functionality:** Provide a RESTful API to query processed data and specifically anomalous records.

### 6. Monitoring & Alerting
-   **Component:** AWS CloudWatch.
-   **Functionality:**
    -   Monitor Lambda invocations, errors, and duration.
    -   Set up alarms for detected anomalies or pipeline failures.
    -   Log all critical events.

## Deliverables Expected from Claude Code

1.  **High-Level System Architecture Diagram (Textual/Markdown):** A clear description of components and data flow, possibly using PlantUML-like syntax in markdown for visual representation.
2.  **Core Lambda Function Code (Python):**
    -   `ingestion_processor.py`: Handles data validation, enrichment, and initial transformation.
    -   `anomaly_detector.py`: Integrates with a conceptual ML model endpoint.
3.  **Data Schemas (JSON):** Define input, processed, and anomaly data schemas.
4.  **Deployment Instructions (Conceptual):** Outline the steps or provide a conceptual CloudFormation structure (YAML/JSON) for deploying the resources.
5.  **Comprehensive Documentation:** Explain the design choices, how to set up, run, and test the pipeline, and considerations for scalability and cost optimization.
6.  **Makefile or Script (Conceptual):** A simple build/deploy script (bash) for the provided code.

## Constraints & Best Practices
-   Prioritize serverless services to minimize operational overhead.
-   Emphasize modularity, reusability, and maintainability of code.
-   Consider security best practices (IAM roles, least privilege).
-   Focus on a practical, illustrative example rather than a production-ready system (but production-ready principles should be applied).
-   Provide clear explanations and comments within the code and documentation.

## Output Format
Please provide your response in a structured markdown format, including all requested code snippets, architectural descriptions, and documentation within the response.
