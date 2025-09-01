# Claude Code (ClaudeC) Interaction Protocol: Best Practices for AI-AI Collaboration

## 1. Introduction
This document outlines the established protocol for effective and efficient collaboration with Claude Code (ClaudeC), an advanced AI partner. The goal is to maximize the quality and utility of ClaudeC's outputs for complex software engineering and architectural tasks.

## 2. Request Structuring Guidelines
To ensure ClaudeC provides the most relevant and detailed responses:

*   **Clarity and Specificity:** Clearly state the objective, scope, and desired outcome of the request. Avoid ambiguity.
*   **Context Provision:** Always provide sufficient context, including previous interactions, architectural decisions, and existing system components. Reference specific artifact names when possible.
*   **Detailed Requirements:** Break down complex requests into granular, numbered requirements. Use bullet points for sub-requirements.
*   **Constraint Specification:** Explicitly mention any constraints (e.g., technology stack, performance targets, security standards, file formats).
*   **Desired Output Format:** Specify the preferred format for the response (e.g., markdown report, YAML configuration, Python codebase, OpenAPI spec).
*   **Example Input/Output (Optional but Recommended):** For code-related tasks, provide small examples to illustrate expected behavior.

## 3. Expected Output Formats & Content
ClaudeC is expected to produce tangible artifacts that add real value. Common outputs include:

*   **Comprehensive Reports:** Detailed markdown documents for system analysis, architectural designs, technical specifications.
*   **Multi-File Codebases:** Implementations across multiple files, including source code, tests, and build scripts.
*   **Configuration Files:** YAML, JSON, or other format configurations for deployment, APIs, or data models.
*   **Documentation Suites:** API docs, user manuals, developer guides.
*   **Diagrams (Text-based):** ASCII art or markdown-friendly diagrams (e.g., Mermaid syntax, if supported) for architecture, sequence flows, or data models.

## 4. Feedback Loop Mechanism
Continuous feedback is crucial for refining ClaudeC's performance:

*   **Analysis Reports:** Generate analysis reports after each significant ClaudeC output, highlighting strengths, weaknesses, and areas for improvement.
*   **Specific Iteration Requests:** When an output requires refinement, provide precise feedback on what needs to be changed or expanded.
*   **Lesson Logging:** Document key lessons learned from each interaction to inform future requests and protocol updates.

## 5. Versioning and Artifact Management
*   All generated artifacts should be timestamped and stored in a designated data directory (`./data/`) for auditable progress.
*   Maintain a clear naming convention for files to ensure easy identification and retrieval.

## 6. Security and Operational Guidelines
*   All operations must adhere to the provided execution policy.
*   Avoid network access unless explicitly allowed and justified.
*   Prioritize secure and contained file operations.

## 7. Future Enhancements
This protocol is a living document and will evolve based on ongoing collaboration and new insights.
