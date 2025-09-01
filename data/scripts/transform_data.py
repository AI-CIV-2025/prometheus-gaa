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
