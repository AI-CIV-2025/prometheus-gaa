import json
import os
import boto3

kinesis_client = boto3.client('kinesis')
STREAM_NAME = os.environ.get('KINESIS_STREAM_NAME', 'iot-data-stream')

def handler(event, context):
    """
    AWS Lambda function to ingest IoT data via API Gateway and publish to Kinesis.
    """
    print(f"Received event: {json.dumps(event)}")

    try:
        # Assuming API Gateway proxy integration
        body = json.loads(event['body'])
        device_id = body.get('device_id')
        timestamp = body.get('timestamp')

        if not device_id or not timestamp:
            return {
                'statusCode': 400,
                'body': json.dumps({'message': 'Missing device_id or timestamp'})
            }

        # Publish to Kinesis
        kinesis_client.put_record(
            StreamName=STREAM_NAME,
            Data=json.dumps(body),
            PartitionKey=device_id # Use device_id for consistent partitioning
        )

        print(f"Successfully published data for device {device_id} to Kinesis.")

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Data ingested successfully'})
        }

    except json.JSONDecodeError:
        print("Invalid JSON payload.")
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Invalid JSON payload'})
        }
    except Exception as e:
        print(f"Error processing request: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': f'Internal server error: {str(e)}'})
        }

if __name__ == '__main__':
    # Example usage for local testing (won't run in Lambda)
    print("Running local test for lambda_ingest")
    mock_event = {
        'body': json.dumps({
            "device_id": "iot-sensor-001",
            "timestamp": "2025-08-31T10:00:00Z",
            "temperature": 25.5,
            "humidity": 60.2,
            "location": {"lat": 34.0522, "lon": -118.2437}
        })
    }
    response = handler(mock_event, None)
    print(f"Mock response: {response}")
