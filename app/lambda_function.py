import sys

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": f"Hello from Lambda using Python {sys.version}"
    }
