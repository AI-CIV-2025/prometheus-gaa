# Serverless Data Processing Pipeline: Design Document

## 1. Architecture Overview
The pipeline leverages AWS serverless services to create an event-driven data processing flow.
- **S3 (Raw Data Bucket):** Ingestion point for raw CSV/JSON files.
- **S3 Event Notification:** Triggers an AWS Lambda function upon new object creation.
- **AWS Lambda (Processor Function):** Core compute for validation, transformation, and enrichment.
- **DynamoDB (Processed Data Table):** Stores structured, refined data.
- **S3 (Error Data Bucket):** Destination for files that fail processing.
- **CloudWatch:** For logging and monitoring.
