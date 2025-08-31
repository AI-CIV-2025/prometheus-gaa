# Claude Code Project Output Template

This template outlines the expected structure for comprehensive project outputs from Claude Code.
Please organize your response into the following sections and provide the requested files.

## 1. Project Overview & Design Document (design_doc.md)
- **File:** `design_doc.md`
- **Content:**
  - High-level system architecture (e.g., microservices, monorepo, serverless)
  - Key components and their responsibilities
  - Data flow diagrams (conceptual)
  - Technology stack justification
  - API specifications (if applicable)
  - Database schema design (conceptual)
  - Scalability and security considerations

## 2. Core Codebase (src/ directory)
- **Directory:** `./src/`
- **Content:**
  - Well-structured code files implementing the core functionality.
  - Multiple files for different modules/components.
  - Example: `src/main.py`, `src/services/data_processor.py`, `src/api/routes.js`
  - Include necessary configuration files (e.g., `config.json`, `.env.example`).
  - Include dependency management files (e.g., `requirements.txt`, `package.json`).

## 3. Comprehensive Documentation (docs/ directory)
- **Directory:** `./docs/`
- **Content:**
  - **Installation Guide:** `docs/installation.md` (detailed steps for setup)
  - **Usage Guide:** `docs/usage.md` (how to use the system/APIs)
  - **Developer Guide:** `docs/developer.md` (how to contribute, code standards)
  - **Troubleshooting Guide:** `docs/troubleshooting.md` (common issues and solutions)
  - **README.md:** (at root of the project, summary of project)

## 4. Test Suite (tests/ directory)
- **Directory:** `./tests/`
- **Content:**
  - Unit tests for core functions.
  - Integration tests (if applicable).
  - Example: `tests/unit/test_processor.py`, `tests/integration/test_api.js`

## 5. Deployment Instructions (deployment/ directory)
- **Directory:** `./deployment/`
- **Content:**
  - Dockerfiles (if containerization is used).
  - Kubernetes manifests (if applicable).
  - Deployment scripts (e.g., `deploy.sh`).
  - Cloud-specific configuration files (e.g., AWS CloudFormation, Azure ARM templates).

## 6. Reflections & Learnings (reflections.md)
- **File:** `reflections.md`
- **Content:**
  - Challenges encountered during design/implementation.
  - Design choices and trade-offs.
  - Potential future improvements or features.
  - Any assumptions made.

Please ensure all files are placed in their respective directories within the overall project structure.
