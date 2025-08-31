#TASK Design and implement a highly scalable, real-time, fault-tolerant AI-powered anomaly detection system for industrial IoT sensors.

**Mission Objective:** Create a comprehensive solution that can ingest high-volume sensor data, detect anomalies in real-time using AI/ML models, and trigger alerts.

**Detailed Requirements:**

1.  **System Architecture:**
    *   Provide a detailed architectural diagram (conceptual description) and explanation.
    *   Components should cover: data ingestion (e.g., Kafka, MQTT broker), real-time processing (e.g., stream processing framework), anomaly detection module, data storage (e.g., time-series DB), and an alerting mechanism.
    *   Emphasize scalability, fault tolerance, and low-latency processing.

2.  **Core Codebase (Multi-file Python):**
    *   **Sensor Data Generator (`sensor_simulator.py`):** A Python script to simulate industrial IoT sensor data, including occasional anomalous readings. Should generate data in a structured format (e.g., JSON).
    *   **Data Ingestion/Pre-processing (`data_processor.py`):** A Python script that would conceptually connect to the data stream, perform basic cleaning/normalization, and prepare data for the anomaly detection model.
    *   **Anomaly Detection Module (`anomaly_detector.py`):**
        *   Implement a suitable AI/ML algorithm for anomaly detection (e.g., Isolation Forest, Autoencoders, LSTM-based anomaly detection).
        *   Provide training and inference logic.
        *   Explain the choice of algorithm.
    *   **Alerting Mechanism (`alerter.py`):** A simple Python script to simulate sending alerts (e.g., print to console, or mock an API call).
    *   **Main Application (`main.py`):** Orchestrate the above components.

3.  **Documentation:**
    *   `README.md`: Setup instructions, how to run the system, and a brief overview.
    *   API Endpoints (if applicable): Describe any APIs for data ingestion or querying.
    *   Deployment Considerations: Discuss potential deployment strategies (e.g., Docker, Kubernetes, cloud services).

4.  **Dependencies:**
    *   Provide a `requirements.txt` file listing all necessary Python libraries.

5.  **Test Cases:**
    *   Describe simple test scenarios to validate the anomaly detection logic (e.g., inject known anomalies and verify detection).

**Expected Output:** A comprehensive markdown response containing all the above, with clear code blocks and explanations.
