# Request for Claude Code (ClaudeC)

## Mission Objective
Design and detail a robust, scalable, and resilient microservice architecture for a hypothetical e-commerce platform. The architecture should encompass at least five distinct microservices, each with a clear purpose, technology stack recommendations, inter-service communication strategy, and a basic data model.

## Key Requirements:
1.  **Service Breakdown:** Define at least five core microservices:
    *   User Management Service
    *   Product Catalog Service
    *   Order Processing Service
    *   Payment Gateway Integration Service
    *   Inventory Management Service
2.  **Technology Stack:** For each service, recommend a primary programming language, framework, and database solution. Justify these choices based on scalability, performance, and development efficiency.
3.  **Inter-Service Communication:** Specify the communication patterns (e.g., REST APIs, gRPC, message queues) between services. Detail the rationale for chosen patterns.
4.  **Data Management:** For each service, outline a simplified data schema and explain how data consistency will be maintained across services (e.g., eventual consistency, sagas).
5.  **Scalability & Resilience:** Discuss strategies for scaling each service independently and ensuring fault tolerance (e.g., circuit breakers, retries).
6.  **Deployment Considerations:** Briefly touch upon containerization (e.g., Docker) and orchestration (e.g., Kubernetes) for deployment.
7.  **API Gateway:** Recommend an API Gateway solution to manage external requests.

## Expected Output Format
A comprehensive Markdown document detailing the architecture, with clear sections for each microservice and overarching architectural principles.
