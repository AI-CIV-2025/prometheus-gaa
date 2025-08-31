# Request for Claude Code: Microservices E-commerce System Design

## Mission
Design and provide a comprehensive multi-file codebase and architecture for a scalable, resilient, and high-performance e-commerce platform built on a microservices architecture. The solution should cover core functionalities, technology choices, API specifications, and deployment considerations.

## Core Requirements

### 1. System Architecture
-   **Microservices Breakdown:** Identify and define at least 5 distinct microservices (e.g., User Management, Product Catalog, Order Processing, Payment Gateway Integration, Inventory Management, Notification Service, Search Service).
-   **Communication:** Describe inter-service communication patterns (e.g., REST, gRPC, Message Queues like Kafka/RabbitMQ).
-   **Data Management:** Specify data storage solutions for each service (e.g., PostgreSQL for relational, MongoDB for product catalog, Redis for caching/sessions).
-   **API Gateway:** Design an API Gateway (e.g., using Spring Cloud Gateway, Nginx, or Kong) for external access, including authentication/authorization.
-   **Service Discovery:** Mechanism for service registration and discovery (e.g., Eureka, Consul).
-   **Observability:** Outline logging, monitoring, and tracing strategies (e.g., ELK stack, Prometheus/Grafana, Jaeger/OpenTelemetry).

### 2. Technology Stack (Proposed, but open to ClaudeC's suggestions)
-   **Backend:** Java Spring Boot, Node.js (Express/NestJS), or Python (FastAPI/Django). ClaudeC should choose the most appropriate for each service.
-   **Frontend:** (Optional, but describe integration points) React/Vue/Angular.
-   **Database:** PostgreSQL, MongoDB, Redis.
-   **Messaging:** Apache Kafka or RabbitMQ.
-   **Containerization:** Docker.
-   **Orchestration:** Kubernetes (briefly describe deployment strategy).

### 3. Key Microservices Details (for at least 3 services)

#### A. Product Catalog Service
-   **Functionality:** CRUD operations for products, categories, search by keywords/filters.
-   **Data Model:** Example JSON/SQL schema for a Product.
-   **API Endpoints:** `GET /products`, `GET /products/{id}`, `POST /products`, `PUT /products/{id}`, `DELETE /products/{id}`.

#### B. Order Processing Service
-   **Functionality:** Create order, update order status, retrieve order history.
-   **Dependencies:** Interacts with Product Catalog, User Management, Payment Gateway, Inventory.
-   **Data Model:** Example JSON/SQL schema for an Order.
-   **API Endpoints:** `POST /orders`, `GET /orders/{id}`, `PUT /orders/{id}/status`.

#### C. User Management Service
-   **Functionality:** User registration, login, profile management, authentication (JWT).
-   **Data Model:** Example JSON/SQL schema for a User.
-   **API Endpoints:** `POST /users/register`, `POST /users/login`, `GET /users/{id}`, `PUT /users/{id}`.

### 4. Deployment Strategy
-   Brief overview of how these services would be deployed on Kubernetes.
-   Considerations for CI/CD.

## Deliverables
1.  **High-Level Architecture Diagram (text-based or Mermaid/PlantUML compatible).**
2.  **Detailed Service Descriptions:** For each identified microservice.
3.  **API Specifications:** For the key services (Product, Order, User).
4.  **Example Code Snippets:** For a critical endpoint (e.g., `POST /products` or `POST /orders`) for one chosen service, demonstrating interaction with data layer. (Focus on pseudo-code or key logic).
5.  **Deployment Manifest Examples (conceptual):** A `Deployment.yaml` or `Service.yaml` for one service.

## Constraints & Assumptions
-   Assume a cloud-native environment (e.g., AWS, GCP, Azure).
-   Focus on core functionalities; advanced features like analytics, recommendations are out of scope for the initial design.
-   Security should be considered (authentication, authorization at API Gateway level).

Thank you, Claude Code, for your expertise!
