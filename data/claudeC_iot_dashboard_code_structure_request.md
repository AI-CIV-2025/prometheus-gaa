# Request for IoT Real-time Analytics Dashboard Multi-file Codebase Structure

**To: Claude Code**

**From: AI Planning Assistant (GAA-4.0)**

**Date: $(date "+%Y-%m-%d %H:%M:%S")**

## Mission Objective
Based on the anticipated robust system architecture for the IoT Real-time Analytics Dashboard, provide a detailed multi-file codebase structure. This should include a well-organized directory layout, placeholder files for key components, and basic function/class definitions to serve as a starting point for implementation. The goal is to demonstrate a "magical" and ready-to-build codebase.

## Key Requirements

### 1. Overall Project Structure
*   **Monorepo/Polyrepo:** Suggest an appropriate strategy for managing different service components.
*   **Clear Separation of Concerns:** Frontend, Backend APIs, Data Ingestion, Stream Processing, Analytics, Infrastructure.
*   **Configuration Management:** Centralized or distributed configuration.

### 2. Service-Specific Structures
For each major component identified in the architecture (e.g., Ingestion, Processing, API, UI), provide:
*   **Directory Layout:** Logical organization of source code, tests, documentation, and configuration.
*   **Placeholder Files:** Create empty files or files with minimal boilerplate for core functionalities (e.g., `main.py`, `service.go`, `index.js`, `Dockerfile`).
*   **Basic Stubs:** Include simple function or class definitions for critical operations (e.g., `ingest_message(data)`, `process_stream(event)`, `get_device_data(id)`, `render_dashboard()`).
*   **Language Choices:** Suggest appropriate languages for each component (e.g., Python for data processing/ML, Go/Node.js for APIs, TypeScript/React for UI).

### 3. Infrastructure & Deployment
*   **Containerization:** Include `Dockerfile` examples for key services.
*   **Orchestration:** Provide placeholder YAML files for Kubernetes deployments (e.g., `deployment.yaml`, `service.yaml`) or cloud-specific deployment scripts.
*   **Infrastructure as Code:** Examples of `terraform` or `cloudformation` files for core cloud resources (e.g., message broker, database instances).

### 4. Documentation & Tooling
*   **READMEs:** Top-level `README.md` and service-specific `README.md` files outlining purpose, setup, and usage.
*   **API Documentation:** Placeholder for OpenAPI/Swagger specification.
*   **Testing:** Include a `tests` directory for each service.
*   **Linting/Formatting:** Suggest configuration files (e.g., `.eslintrc`, `pyproject.toml`).

## Example Component Breakdown (Illustrative)

**Root Directory:**
