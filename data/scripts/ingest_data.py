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
