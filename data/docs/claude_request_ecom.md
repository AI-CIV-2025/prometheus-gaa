# Request for Claude Code: Microservices E-commerce System Architecture

## Mission Objective
Design a comprehensive, scalable, and resilient microservices-based e-commerce system. The solution should cover architecture, technology stack, deployment, CI/CD, and operational aspects.

## Core Requirements
1.  **System Architecture:** Provide a high-level and detailed microservices architecture diagram (text-based or descriptive).
2.  **Service Breakdown:** Identify core services (e.g., User, Product Catalog, Order Management, Payment Processing, Inventory, Notification, Search) and their responsibilities.
3.  **Technology Stack:** Suggest appropriate technologies for each service (languages, frameworks, databases, messaging queues).
4.  **API Design:** Outline RESTful API principles, common endpoints, and data models for key interactions.
5.  **Inter-service Communication:** Detail strategies for synchronous (e.g., HTTP/gRPC) and asynchronous (e.g., Kafka, RabbitMQ) communication, including event structures.
6.  **Data Management:** Address data partitioning, consistency models (e.g., eventual consistency), and database choices for different service needs.
7.  **Deployment Strategy:** Propose a containerization (Docker) and orchestration (Kubernetes) strategy, including deployment manifests concepts.
8.  **CI/CD Pipeline:** Design a robust CI/CD workflow (e.g., using GitHub Actions, GitLab CI) from code commit to production deployment.
9.  **Monitoring & Logging:** Recommend tools and strategies for observability (e.g., Prometheus, Grafana, ELK Stack, distributed tracing).
10. **Security:** Outline authentication (e.g., OAuth2, JWT), authorization, input validation, and secure communication practices.
11. **Documentation Suite:** Specify the types of documentation needed (API docs, architecture diagrams, deployment guides, runbooks).
12. **Scalability & Resilience:** Describe how the system will handle high traffic, fault tolerance, and disaster recovery.

## Specific Challenges to Address
*   **Distributed Transactions:** How to manage transactions that span multiple microservices (e.g., Order creation involving Inventory deduction and Payment).
*   **Data Consistency:** Strategies for maintaining data consistency across different services and databases.
*   **API Gateway:** Role and implementation details of an API Gateway (e.g., routing, authentication, rate limiting).

## Expected Output
A multi-file codebase structure, detailed architectural descriptions, conceptual code snippets for key interactions, and comprehensive documentation outlines.
