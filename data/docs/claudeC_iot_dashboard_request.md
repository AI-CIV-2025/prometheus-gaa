# Request for Claude Code: Real-time IoT Data Analytics Dashboard

## Mission
Design and develop a comprehensive, multi-component, real-time IoT data analytics dashboard system. This system should be capable of ingesting, processing, storing, and visualizing data from a fleet of IoT devices.

## Key Requirements

### 1. System Architecture
Provide a detailed system architecture diagram (text-based or conceptual description) including:
- Data Ingestion Layer (e.g., MQTT, Kafka)
- Data Processing Layer (e.g., Stream processing, Lambda functions)
- Data Storage Layer (e.g., Time-series database, NoSQL database)
- API Layer for data access
- Frontend Visualization Layer (e.g., Web dashboard)
- Security considerations (authentication, authorization, data encryption)
- Scalability and High Availability considerations

### 2. Core Components (Code & Configuration)
For each major component, provide:
- **Data Model:** JSON/YAML schema for typical IoT device data (e.g., sensor readings: temperature, humidity, pressure, device ID, timestamp, location).
- **Ingestion Script/Configuration:** Example code (Python/Node.js) or configuration for a data ingestion service.
- **Processing Logic:** Example code (Python/Node.js) for a simple data transformation/aggregation function.
- **Database Schema/Configuration:** Example DDL for a time-series database (e.g., InfluxDB, TimescaleDB) or schema definition for a NoSQL DB (e.g., MongoDB).
- **API Endpoint Specification:** OpenAPI/Swagger YAML for key endpoints (e.g., /devices, /data/{deviceId}, /metrics).
- **Frontend Mockup/Component Ideas:** HTML/CSS/JS snippets or conceptual design for dashboard widgets (e.g., real-time charts, device list, alerts).

### 3. Deployment & Operations
- **Deployment Strategy:** High-level steps for deploying the system (e.g., Docker Compose, Kubernetes, Serverless).
- **Monitoring & Alerting:** Suggestions for key metrics to monitor and example alert rules.

### 4. Documentation
Provide a `README.md` that explains how to set up, run, and interact with the system, along with an `ARCHITECTURE.md` detailing the design choices.

## Output Format
Please structure your response according to the `claudeC_output_template.md` provided previously. Ensure all code examples are clearly marked and runnable (or pseudo-code if full implementation is too large). Organize files into logical subdirectories.
