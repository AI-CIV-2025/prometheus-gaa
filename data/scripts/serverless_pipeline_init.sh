#!/bin/bash
# This script initializes the directory structure and basic files for a serverless data pipeline.

# Define base directory
BASE_DIR="./data/serverless_pipeline"
mkdir -p "$BASE_DIR/src/lambda_functions"
mkdir -p "$BASE_DIR/tests"
mkdir -p "$BASE_DIR/config"
mkdir -p "$BASE_DIR/data_artifacts"

# Create initial configuration files
cat << 'CONFIG_EOF' > "$BASE_DIR/config/pipeline_config.json"
{
  "pipeline_name": "ai_collaboration_data_processor",
  "version": "1.0.0",
  "stages": [
    {
      "name": "data_ingestion",
      "lambda_function": "ingest_data.py",
      "description": "Handles incoming data ingestion."
    },
    {
      "name": "data_transformation",
      "lambda_function": "transform_data.py",
      "description": "Performs data cleaning and transformation."
    },
    {
      "name": "data_analysis",
      "lambda_function": "analyze_data.py",
      "description": "Conducts data analysis and generates insights."
    }
  ],
  "output_bucket": "ai-collaboration-results"
}
CONFIG_EOF

# Create placeholder Lambda function files (Python)
cat << 'LAMBDA_INGEST_EOF' > "$BASE_DIR/src/lambda_functions/ingest_data.py"
import json
import os

def lambda_handler(event, context):
    print("Ingesting data...")
    # Placeholder for actual data ingestion logic
    data = event.get('data', {})
    print(f"Received data: {data}")
    
    # Simulate saving ingested data artifact
    output_path = os.path.join(os.environ.get('DATA_ARTIFACTS_PATH', './data_artifacts'), 'ingested_data.json')
    with open(output_path, 'w') as f:
        json.dump(data, f)
    print(f"Ingested data saved to {output_path}")

    return {
        'statusCode': 200,
        'body': json.dumps('Data ingestion successful!')
    }
LAMBDA_INGEST_EOF

cat << 'LAMBDA_TRANSFORM_EOF' > "$BASE_DIR/src/lambda_functions/transform_data.py"
import json
import os

def lambda_handler(event, context):
    print("Transforming data...")
    # Placeholder for actual data transformation logic
    input_path = os.path.join(os.environ.get('DATA_ARTIFACTS_PATH', './data_artifacts'), 'ingested_data.json')
    if not os.path.exists(input_path):
        return {'statusCode': 400, 'body': json.dumps('Input data not found.')}

    with open(input_path, 'r') as f:
        data = json.load(f)
    
    transformed_data = {"processed_value": data.get("value", 0) * 2}
    print(f"Transformed data: {transformed_data}")

    # Simulate saving transformed data artifact
    output_path = os.path.join(os.environ.get('DATA_ARTIFACTS_PATH', './data_artifacts'), 'transformed_data.json')
    with open(output_path, 'w') as f:
        json.dump(transformed_data, f)
    print(f"Transformed data saved to {output_path}")

    return {
        'statusCode': 200,
        'body': json.dumps('Data transformation successful!')
    }
LAMBDA_TRANSFORM_EOF

cat << 'LAMBDA_ANALYZE_EOF' > "$BASE_DIR/src/lambda_functions/analyze_data.py"
import json
import os

def lambda_handler(event, context):
    print("Analyzing data...")
    # Placeholder for actual data analysis logic
    input_path = os.path.join(os.environ.get('DATA_ARTIFACTS_PATH', './data_artifacts'), 'transformed_data.json')
    if not os.path.exists(input_path):
        return {'statusCode': 400, 'body': json.dumps('Transformed data not found.')}
    
    with open(input_path, 'r') as f:
        data = json.load(f)

    analysis_result = {"insight": f"Processed value is {data.get('processed_value', 'N/A')}"}
    print(f"Analysis result: {analysis_result}")

    # Simulate saving analysis result artifact
    output_path = os.path.join(os.environ.get('DATA_ARTIFACTS_PATH', './data_artifacts'), 'analysis_result.json')
    with open(output_path, 'w') as f:
        json.dump(analysis_result, f)
    print(f"Analysis result saved to {output_path}")

    return {
        'statusCode': 200,
        'body': json.dumps('Data analysis successful!')
    }
LAMBDA_ANALYZE_EOF

# Create placeholder test file
cat << 'TEST_EOF' > "$BASE_DIR/tests/test_ingestion.py"
import unittest
# Placeholder for test cases

class TestIngestion(unittest.TestCase):
    def test_placeholder(self):
        self.assertTrue(True)

if __name__ == '__main__':
    unittest.main()
TEST_EOF

echo "Created serverless pipeline structure and initial files in ./data/serverless_pipeline"
echo "Initial config: ./data/serverless_pipeline/config/pipeline_config.json"
echo "Lambda functions: ./data/serverless_pipeline/src/lambda_functions/"
echo "Tests: ./data/serverless_pipeline/tests/"
