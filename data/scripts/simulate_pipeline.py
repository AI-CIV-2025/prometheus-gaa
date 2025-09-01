import json
import os
import subprocess

# Ensure EXECUTION_PATH is respected
BASE_DIR = "./data/serverless_pipeline"
ARTIFACTS_DIR = os.path.join(BASE_DIR, "data_artifacts")
PYTHON_EXECUTABLE = "python3" # Assuming python3 is available

def run_command(command):
    """Runs a shell command and returns its output."""
    print(f"Executing: {' '.join(command)}")
    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        print(result.stdout)
        if result.stderr:
            print(f"Stderr: {result.stderr}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        print(f"Stderr: {e.stderr}")
        return False
    except FileNotFoundError:
        print(f"Error: Command '{command[0]}' not found. Ensure it's in your PATH.")
        return False

def simulate_stage(stage_config, input_data_path=None):
    """Simulates the execution of a single pipeline stage."""
    function_name = stage_config['lambda_function']
    function_path = os.path.join(BASE_DIR, "src", "lambda_functions", function_name)
    
    # Prepare the event payload
    event_payload = {}
    if input_data_path and os.path.exists(input_data_path):
        with open(input_data_path, 'r') as f:
            try:
                event_payload['data'] = json.load(f)
            except json.JSONDecodeError:
                print(f"Warning: Could not decode JSON from {input_data_path}. Passing raw content.")
                f.seek(0)
                event_payload['data'] = f.read()
    elif input_data_path:
        print(f"Warning: Input data path not found: {input_data_path}")
        
    # Prepare environment variables for the Lambda function
    env_vars = {
        "DATA_ARTIFACTS_PATH": ARTIFACTS_DIR
    }
    
    # Construct the command to execute the Python script as a Lambda function
    # This is a simplified simulation; real Lambda execution involves more context.
    command = [
        PYTHON_EXECUTABLE, 
        function_path
    ]

    # Simulate passing event data via stdin for simplicity in this simulation
    # In a real scenario, this would be handled by the Lambda runtime environment.
    print(f"\n--- Simulating Stage: {stage_config['name']} ---")
    print(f"Lambda Function: {function_name}")
    
    # Create a temporary file for the event payload
    event_file = os.path.join(ARTIFACTS_DIR, "event.json")
    with open(event_file, 'w') as f:
        json.dump(event_payload, f)

    # Construct the command using python -c to pass the event via stdin
    # Note: This requires the lambda function script to read from stdin for the event.
    # Modifying the lambda scripts to accept event via stdin is needed for this simulation approach.
    # For simplicity, we'll call the script directly and pass the event as an argument (less realistic Lambda simulation).
    
    # Alternative: Execute directly and pass event as argument (if script supports it)
    # Let's adjust the lambda scripts slightly or assume they read event from a file passed as arg.
    # For this simulation, we'll execute the script directly and pass the event file path.
    
    # Simpler approach: Directly invoke the handler function with the event payload.
    # This requires importing the script and calling the handler.
    try:
        import sys
        sys.path.insert(0, os.path.join(BASE_DIR, "src", "lambda_functions"))
        
        module_name = function_name.replace('.py', '')
        module = __import__(module_name)
        
        print(f"Invoking handler: {module.lambda_handler.__name__}")
        
        # Simulate setting the DATA_ARTIFACTS_PATH environment variable
        os.environ.update(env_vars)
        
        response = module.lambda_handler(event_payload, {}) # Empty context object
        
        print(f"Stage Response: {response}")
        
        # Clean up the temporary event file
        if os.path.exists(event_file):
            os.remove(event_file)
        
        return response.get('statusCode') == 200
        
    except ImportError:
        print(f"Error: Could not import module {module_name}. Ensure it's in the path.")
        return False
    except AttributeError:
        print(f"Error: 'lambda_handler' not found in {function_name}.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred during simulation: {e}")
        return False


def main():
    print("Starting Serverless Data Pipeline Simulation...")
    
    # Ensure artifacts directory exists
    os.makedirs(ARTIFACTS_DIR, exist_ok=True)
    
    # Load pipeline configuration
    config_path = os.path.join(BASE_DIR, "config", "pipeline_config.json")
    if not os.path.exists(config_path):
        print(f"Error: Pipeline configuration not found at {config_path}")
        return

    with open(config_path, 'r') as f:
        config = json.load(f)

    pipeline_stages = config.get('stages', [])
    
    current_input_path = None # Start with no specific input path for the first stage
    
    for stage in pipeline_stages:
        stage_name = stage['name']
        
        # Determine input path for the current stage
        if stage_name == "data_ingestion":
            # Ingestion doesn't read a previous artifact, it receives input via event
            input_artifact_path = None 
        elif stage_name == "data_transformation":
            input_artifact_path = os.path.join(ARTIFACTS_DIR, "ingested_data.json")
        elif stage_name == "data_analysis":
            input_artifact_path = os.path.join(ARTIFACTS_DIR, "transformed_data.json")
        else:
            input_artifact_path = None # Default case

        if not simulate_stage(stage, input_data_path=input_artifact_path):
            print(f"Pipeline simulation failed at stage: {stage_name}")
            return
        
        # Update current_input_path for the next iteration (not directly used in this simplified loop)
        # The logic is now handled within simulate_stage based on stage_name

    print("\nServerless Data Pipeline Simulation Completed Successfully!")
    print(f"Check ./data/serverless_pipeline/data_artifacts/ for generated files.")
    
    # List generated artifacts
    print("\nGenerated Artifacts:")
    for artifact in os.listdir(ARTIFACTS_DIR):
        print(f"- {artifact}")

if __name__ == "__main__":
    # Create a dummy input file for the first stage if it doesn't exist
    dummy_input_data = {"value": 42}
    initial_input_file = os.path.join(ARTIFACTS_DIR, "initial_input.json")
    if not os.path.exists(initial_input_file):
        with open(initial_input_file, 'w') as f:
            json.dump(dummy_input_data, f)
        print(f"Created dummy input file: {dummy_input_data}")
    
    # Modify the simulate_stage function to handle the initial input for ingest_data
    # Let's adjust the simulation logic slightly:
    # The ingest_data.py script expects event['data']. We will pass the dummy_input_data directly in the event.
    
    main()
