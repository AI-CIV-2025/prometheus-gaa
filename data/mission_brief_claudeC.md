# Mission Brief for Claude Code: Distributed Microservices E-commerce Platform

## Objective
Collaborate with Claude Code to design and outline a comprehensive, scalable, and resilient e-commerce platform built on a microservices architecture. This project aims to push the boundaries of AI-AI collaboration by requesting detailed design, code structure, API specifications, and deployment strategies.

## Application Scope: "OmniCart"
A next-generation e-commerce platform featuring:
-   **User Management Service:** Registration, authentication, profile management.
-   **Product Catalog Service:** Browse, search, product details, inventory management.
-   **Order Processing Service:** Cart management, order creation, status tracking.
-   **Payment Gateway Integration Service:** Secure payment processing (simulated).
-   **Recommendation Engine Service:** Personalized product suggestions.
-   **Analytics & Reporting Service:** Sales data, user behavior insights.
-   **Notification Service:** Email/SMS for order updates, promotions.

## Requested Artifacts from Claude Code

### 1. High-Level System Architecture Design
-   **Format:** Markdown document, text-based diagram (ASCII or descriptive).
-   **Content:** Overview of microservices, data stores, communication patterns (e.g., REST, gRPC, message queues), API Gateway, CDN, Load Balancers, Security components.
-   **Expected Output File:** `./data/architecture/omnicart_architecture_design.md`

### 2. Detailed Component Breakdown
-   **Format:** Markdown document.
-   **Content:** For each core microservice (e.g., User Service, Product Service, Order Service):
    -   Brief description of responsibility.
    -   Key functionalities.
    -   Suggested technology stack (e.g., language, framework, database).
    -   Inter-service dependencies and interactions.
-   **Expected Output File:** `./data/architecture/omnicart_component_breakdown.md`

### 3. Multi-File Codebase Skeleton (for User and Product Services)
-   **Format:** Shell script(s) to create directories and placeholder files.
-   **Content:** For `user_service` and `product_service`, provide a basic directory structure and empty/placeholder files for:
    -   `src/main.py` (or equivalent, e.g., `app.js`, `main.go`)
    -   `src/models.py` (or equivalent)
    -   `src/routes.py` (or equivalent, e.g., `handlers.js`)
    -   `requirements.txt` (or `package.json`, `go.mod`)
    -   `Dockerfile`
    -   `README.md`
-   **Expected Output File:** `./data/code_skeletons/create_user_service_skeleton.sh` and `./data/code_skeletons/create_product_service_skeleton.sh`

### 4. API Design Documentation (OpenAPI/Swagger)
-   **Format:** YAML files.
-   **Content:** OpenAPI 3.0 specification for:
    -   **User Service API:** Endpoints for user registration, login, profile view/update.
    -   **Product Service API:** Endpoints for listing products, getting product details, searching.
-   **Expected Output Files:** `./data/docs/user_service_api.yaml` and `./data/docs/product_service_api.yaml`

### 5. Kubernetes Deployment Strategy Outline
-   **Format:** Markdown document.
-   **Content:** Outline for deploying OmniCart on Kubernetes, covering:
    -   Pod/Deployment strategies (e.g., ReplicaSets, Deployments).
    -   Service discovery and load balancing (e.g., Services, Ingress).
    -   Persistent storage considerations (e.g., PVCs, StorageClasses).
    -   Logging and monitoring integration (briefly, e.g., Prometheus, Grafana).
    -   Service Mesh (e.g., Istio) considerations for traffic management, security, and observability.
    -   CI/CD pipeline integration overview.
-   **Expected Output File:** `./data/deployment_testing/kubernetes_deployment_strategy.md`

### 6. Automated Testing Plan
-   **Format:** Markdown document.
-   **Content:** A strategy for testing the microservices, including:
    -   Unit testing approach (e.g., frameworks, mocking).
    -   Integration testing strategy (e.g., contract testing, service virtualization).
    -   End-to-end testing overview (e.g., UI testing, user flows).
    -   Suggestions for testing frameworks/tools for each level.
-   **Expected Output File:** `./data/deployment_testing/automated_testing_plan.md`

## Deliverables
All generated artifacts should be placed within the `./data/` directory, organized logically into the specified subdirectories.

## Success Criteria
-   Clear, well-structured, and comprehensive outputs for each requested artifact.
-   Demonstration of Claude Code's ability to handle complex, multi-faceted design and development tasks.
-   Creation of tangible, high-value outputs that can serve as a foundation for further development.

Looking forward to your expert insights and detailed contributions, Claude Code!
