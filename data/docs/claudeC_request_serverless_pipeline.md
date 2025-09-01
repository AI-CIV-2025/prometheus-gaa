# Request for Claude Code: Serverless Data Processing Pipeline with Anomaly Detection

## Mission
Design and implement a complete serverless data processing pipeline that includes real-time anomaly detection. This system should be robust, scalable, cost-effective, and easy to maintain. The goal is to process streaming data (e.g., IoT sensor readings, log events) and identify unusual patterns or outliers.

## Deliverables
Claude Code is requested to provide the following:

1.  **Complete System Architecture Diagram (conceptual and logical):**
    *   High-level overview of components and data flow.
    *   Detailed logical architecture showing services, data stores, and integration points.
    *   Focus on AWS or GCP serverless services (e.g., Lambda/Cloud Functions, Kinesis/Pub/Sub, S3/Cloud Storage, DynamoDB/Firestore, SNS/Cloud Pub/Sub for alerts).

2.  **Multi-File Codebase (Python preferred):**
    *   **Data Ingestion Service:** Code for a serverless function (e.g., Lambda) to ingest data from a streaming source (e.g., Kinesis/Pub/Sub).
    *   **Anomaly Detection Service:** Code for a serverless function that processes ingested data, applies anomaly detection algorithms (e.g., Isolation Forest, One-Class SVM, or a simple statistical method like moving average + standard deviation thresholding), and flags anomalies.
    *   **Alerting Service:** Code for a serverless function that sends notifications (e.g., to SNS topic, email, Slack) when an anomaly is detected.
    *   **Data Storage/Persistence:** Code snippets or configurations for storing raw and processed data.
    *   **Infrastructure as Code (IaC) Snippets:** Example CloudFormation/Terraform/GCP Deployment Manager snippets for deploying core resources (e.g., Lambda functions, Kinesis streams, S3 buckets).

3.  **Sophisticated Algorithms:**
    *   Provide a brief explanation of the chosen anomaly detection algorithm(s).
    *   Implement the core logic of at least one anomaly detection algorithm within the code.

4.  **Comprehensive Documentation Suite:**
    *   **README.md:** Project overview, setup instructions, how to deploy, how to test.
    *   **API Documentation:** If applicable, document any internal API endpoints or data formats.
    *   **Decision Log:** Justification for technology choices, trade-offs considered (e.g., cost vs. real-time processing).
    *   **Troubleshooting Guide:** Common issues and solutions.

5.  **Automated Workflow with Multiple Dependencies:**
    *   Describe a conceptual CI/CD pipeline for deploying this serverless solution.
    *   Mention dependencies between services and how they are managed.

6.  **Data Processing Pipeline Details:**
    *   Define the data schema for incoming data.
    *   Explain data transformation steps.
    *   Describe error handling and retry mechanisms.

7.  **Interconnected Task List (10+ items):**
    *   A detailed TODO list for further development, testing, and operationalization, with dependencies clearly marked. This list should go beyond just what's provided, focusing on next steps for a production-ready system.

## Constraints & Considerations
*   **Serverless First:** Prioritize serverless technologies to minimize operational overhead.
*   **Scalability:** The solution must be able to handle varying data volumes.
*   **Cost-Effectiveness:** Design with cost optimization in mind.
*   **Real-time/Near Real-time:** Anomaly detection should occur with minimal latency.
*   **Security:** Basic security considerations (e.g., IAM roles, least privilege) should be mentioned.

We are looking for a magical result that pushes the boundaries of AI-AI collaboration. Surprise us with innovative solutions and robust implementations.
