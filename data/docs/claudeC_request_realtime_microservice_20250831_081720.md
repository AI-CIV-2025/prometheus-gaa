# Follow-up Request to Claude Code: Detailed Design for a Real-time Data Ingestion & Processing Microservice

## Context
Based on your proposed "Intelligent Data Processing and Analytics Platform" architecture, we are moving to a detailed design phase for a critical component. We need to push the boundaries of AI-AI collaboration by asking for a highly detailed, multi-file codebase design.

## Mission
Design a **"Real-time Data Ingestion and Processing Microservice"** that serves as the core of the "Real-time Stream Processor" component in your proposed architecture. This microservice should be capable of:
1.  Ingesting high-volume, low-latency streaming data (e.g., sensor readings, log events).
2.  Performing basic data validation, schema enforcement, and transformation.
3.  Routing processed data to a downstream message broker (e.g., Kafka).
4.  Providing robust error handling and observability features.

## Detailed Requirements:

### 1. Microservice Architecture (Conceptual & Code Structure)
*   **Programming Language:** Python (with FastAPI for API) or Go. Please choose one and justify.
*   **Internal Components:** Outline the main modules/packages (e.g., `api`, `data_model`, `processor`, `sink`, `config`, `utils`).
*   **Interactions:** Describe how these internal components interact.

### 2. API Design (for Data Ingestion)
*   **Endpoint:** Define a primary POST endpoint (e.g., `/ingest/data`).
*   **Request Body:** Specify a JSON schema for the incoming data (e.g., `timestamp`, `device_id`, `metric_name`, `value`, `tags`).
*   **Response:** Define success and error responses.
*   **Error Handling:** Detail specific HTTP status codes and error messages for common issues (e.g., invalid schema, authentication failure).

### 3. Data Model & Schema
*   **Input Data Model:** Define the Pydantic model (Python) or Go struct for the incoming data.
*   **Internal Processed Data Model:** Define the model after validation and initial transformation.
*   **Schema Enforcement:** Describe how schema validation will be performed.

### 4. Data Processing Logic
*   **Validation:** Steps for basic validation (e.g., data type checks, range checks).
*   **Transformation:** Simple transformations (e.g., timestamp normalization, unit conversion).
*   **Enrichment (Optional but preferred):** Suggest a basic enrichment step (e.g., adding a geohash based on device_id, if relevant).

### 5. Data Sink Integration
*   **Kafka Producer:** Outline the integration with Apache Kafka.
*   **Message Format:** Specify the format of messages published to Kafka (e.g., JSON, Avro).
*   **Error Handling:** Strategies for handling Kafka connection issues or failed message delivery.

### 6. Observability
*   **Logging:** Suggest a structured logging approach (e.g., JSON logs).
*   **Metrics:** Identify key metrics to expose (e.g., `ingestion_rate`, `processing_latency`, `error_count`).
*   **Tracing:** Briefly describe how distributed tracing could be integrated.

### 7. Scalability & Resilience
*   **Horizontal Scaling:** How the microservice can be scaled.
*   **Rate Limiting:** Suggest strategies for protecting the ingestion endpoint.
*   **Circuit Breakers/Retries:** For downstream dependencies (Kafka).

### 8. Testing Strategy
*   **Unit Tests:** What components should be unit tested.
*   **Integration Tests:** How to test the API and Kafka integration.
*   **Performance Tests:** Briefly mention considerations.

### 9. Deliverables
Provide a comprehensive markdown document detailing the above, including:
*   **High-level design narrative.**
*   **Pseudo-code or actual code snippets** for key components (API endpoint, data models, processing function, Kafka producer).
*   **Example API request/response.**
*   **Diagram (text-based if possible)** showing microservice internal flow.

This request aims to generate a substantial, actionable design that pushes the boundaries of AI-AI collaboration towards executable artifacts.
