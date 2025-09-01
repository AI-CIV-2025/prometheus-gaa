import json
import os
import datetime

def create_message(sender, recipient, content, timestamp=None):
    """Creates a structured message for AI-to-AI communication."""
    if timestamp is None:
        timestamp = datetime.datetime.now().isoformat()
    return {
        "sender": sender,
        "recipient": recipient,
        "timestamp": timestamp,
        "content": content
    }

def save_message(message, filename="communication_log.jsonl"):
    """Appends a message to a JSON Lines log file."""
    filepath = os.path.join(os.environ.get("EXECUTION_PATH", "./data"), filename)
    with open(filepath, "a") as f:
        f.write(json.dumps(message) + "\\n")

if __name__ == "__main__":
    # Example Usage: Simulating a message from this agent to ClaudeC
    sender_agent = os.environ.get("AGENT_NAME", "AI_Planner")
    recipient_agent = "ClaudeC"
    communication_content = {
        "task_request": "Design a distributed ledger system architecture.",
        "required_outputs": ["architecture_diagram.png", "system_specs.md", "api_endpoints.json"],
        "constraints": ["must be scalable", "must be fault-tolerant"]
    }

    message_to_claude = create_message(sender_agent, recipient_agent, communication_content)
    save_message(message_to_claude)

    print(f"Message sent to {recipient_agent} and logged.")
    print(f"Log file: {os.path.join(os.environ.get('EXECUTION_PATH', './data'), 'communication_log.jsonl')}")
