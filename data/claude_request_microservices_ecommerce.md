# Request for ClaudeC: Microservices-based Event-Driven E-commerce System

## Mission
Design and provide a comprehensive architecture and initial codebase for a scalable,
resilient, and event-driven e-commerce platform using a microservices approach.

## Core Requirements
1.  **Services:**
    -   `Product Catalog Service`: Manages product information (SKU, name, description, price, stock).
    -   `Order Service`: Handles order creation, status updates, and retrieval.
    -   `Inventory Service`: Manages product stock levels, integrates with Order Service for stock reservation/deduction.
    -   `Payment Service`: Simulates payment processing (integration points for external gateways).
    -   `User Service`: Manages user authentication and profiles.
    -   `Notification Service`: Sends email/SMS notifications for order updates.
2.  **Architecture:**
    -   Event-driven communication using a message broker (e.g., Kafka or RabbitMQ).
    -   RESTful APIs for synchronous communication between services and external clients.
    -   Each service should have its own data store (polyglot persistence encouraged).
    -   API Gateway for external access, handling authentication and routing.
    -   Containerization (Dockerfiles) for each service.
3.  **Technology Stack (Suggestions, ClaudeC can propose alternatives):**
    -   Backend: Python (FastAPI/Flask) or Node.js (Express) or Java (Spring Boot).
    -   Databases: PostgreSQL for relational data (e.g., Product Catalog, User), MongoDB for flexible data (e.g., Order details), Redis for caching/session.
    -   Message Broker: Kafka or RabbitMQ.
    -   Container Orchestration: Kubernetes manifests (basic deployment).
4.  **Key Features per Service:**
    -   **Product Catalog:** CRUD operations for products, search, filtering.
    -   **Order:** Create order, view order status, update order status (e.g., pending, processing, shipped, delivered, cancelled).
    -   **Inventory:** Update stock, reserve stock, release stock.
    -   **Payment:** Initiate payment, confirm payment, handle refunds.
    -   **User:** Register, login, view profile, update profile.
    -   **Notification:** Send order confirmation, shipping updates, payment success/failure.

## Deliverables
1.  **High-Level Architecture Diagram:** Visual representation of services, data stores, message broker, API Gateway.
2.  **Service-level API Specifications:** OpenAPI/Swagger definitions for each service's exposed endpoints.
3.  **Core Codebase Structure:**
    -   Separate directories for each microservice.
    -   Basic implementation for key endpoints (e.g., create product, place order).
    -   Dockerfiles for each service.
    -   Example `docker-compose.yml` for local development.
4.  **Database Schemas:** DDL scripts for relational databases, sample JSON structures for NoSQL.
5.  **Event Definitions:** Structure of messages exchanged via the message broker.
6.  **Deployment Notes:** Basic instructions for local setup and potential cloud deployment.

## Constraints & Considerations
-   Focus on a robust, scalable design.
-   Security considerations (authentication, authorization) should be outlined.
-   Error handling and logging mechanisms should be suggested.
-   Keep initial implementations lean but demonstrate core functionality.
