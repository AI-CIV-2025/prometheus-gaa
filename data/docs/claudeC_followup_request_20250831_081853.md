# Follow-up Request to Claude Code: Detailed User Authentication Service Design

## Context
Building upon the high-level microservice architecture previously provided, we require a deep-dive design for the "User Authentication Service." This service is critical for our platform's security and user management.

## Objective
Provide a comprehensive design for the User Authentication Service, covering all aspects from API specification to deployment considerations.

## Detailed Requirements

### 1. API Specification (RESTful)
*   **Endpoints:**
    *   `/auth/register`: User registration (username, email, password)
    *   `/auth/login`: User login (username/email, password), returning JWT/session token
    *   `/auth/refresh-token`: Refresh an expired token (if using refresh tokens)
    *   `/auth/logout`: Invalidate session/token
    *   `/auth/me`: Get current user's profile
    *   `/auth/password/reset-request`: Initiate password reset
    *   `/auth/password/reset`: Complete password reset
    *   `/auth/verify-email`: Email verification endpoint
*   **Request/Response Schemas:** Define JSON payloads for each endpoint, including success and error responses.
*   **Authentication Mechanism:** Specify how JWTs (or similar) will be generated, validated, and used across services.

### 2. Data Model Design
*   **User Entity:** Fields like `id`, `username`, `email`, `password_hash`, `salt`, `is_active`, `is_verified`, `created_at`, `updated_at`, `last_login`.
*   **Session/Token Entity:** Fields for tracking active sessions or refresh tokens (e.g., `user_id`, `token_hash`, `expires_at`, `issued_at`, `device_info`).
*   **Password Reset Token Entity:** Fields for tracking password reset requests (`user_id`, `token_hash`, `expires_at`).
*   **Email Verification Token Entity:** Fields for email verification (`user_id`, `token_hash`, `expires_at`).
*   **Database Choice:** Recommend a suitable database (e.g., PostgreSQL, MongoDB) and justify the choice.

### 3. Core Logic & Workflow
*   **Registration Flow:** Hashing passwords (e.g., bcrypt), email verification process.
*   **Login Flow:** Password verification, token generation, session management.
*   **Token Validation:** How other services will validate tokens issued by this service.
*   **Authorization:** Basic role-based access control (RBAC) considerations.
*   **Error Handling:** Define common error codes and messages (e.g., 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 500 Internal Server Error).

### 4. Technology Stack Recommendations
*   **Primary Language/Framework:** Suggest a robust language/framework (e.g., Python/FastAPI, Node.js/Express, Go/Gin, Java/Spring Boot).
*   **Libraries/Tools:** Specific recommendations for hashing, JWT handling, database access, testing.

### 5. Security Considerations
*   **Data Encryption:** At rest and in transit.
*   **Input Validation:** Prevention of common vulnerabilities (SQL injection, XSS, CSRF).
*   **Rate Limiting:** For login attempts and password resets.
*   **Secrets Management:** Best practices for API keys, database credentials.
*   **Auditing/Logging:** What information should be logged for security monitoring.

### 6. Deployment & Scalability
*   **Containerization:** Dockerfile example or best practices.
*   **Scaling Strategy:** How to handle increased load (horizontal scaling).
*   **Environment Variables:** Configuration management.

## Expected Output
A detailed markdown document outlining all the above points, including code snippets for API definitions (e.g., OpenAPI YAML or pseudocode), data model definitions, and a high-level sequence diagram for key flows (e.g., login, registration).
