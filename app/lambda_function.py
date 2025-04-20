import json
import boto3

sns_client = boto3.client('sns')

# Defina o ARN do seu SNS Topic
SNS_TOPIC_ARN = 'arn:aws:sns:REGION:ACCOUNT_ID:TOPIC_NAME'

def lambda_handler(event, context):
    for record in event['Records']:
        # O DynamoDB Stream inclui dados sobre as operações de inserção, atualização ou exclusão
        event_name = record['eventName']
        new_image = record.get('dynamodb', {}).get('NewImage', {})
        
        # Exemplo de extração de dados do evento
        data = {
            'eventName': event_name,
            'newData': new_image
        }

        '''
        # Publicar a mensagem no SNS
        response = sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps(data),
            Subject='DynamoDB Stream Event'
        )
        '''
        print(f"Mensagem enviada para o SNS")
        print(json.dumps(data))
    return {
        'statusCode': 200,
        'body': json.dumps('Processamento concluído.')
    }