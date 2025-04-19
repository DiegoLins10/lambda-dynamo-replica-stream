# Lambda DynamoDB Stream to SNS

Este projeto contém uma função **AWS Lambda** que é ativada por um **DynamoDB Stream** e envia uma mensagem para um **SNS Topic**.

## Descrição

A função Lambda é configurada para ser ativada automaticamente sempre que uma modificação (inserção, atualização ou exclusão) em uma tabela do DynamoDB for detectada. Quando a função é acionada, ela processa os dados do stream e envia uma mensagem para um **SNS Topic**, permitindo que outras partes do sistema ou aplicações sejam notificadas sobre a alteração.

## Arquitetura

1. **DynamoDB Stream**: Toda vez que há uma modificação em uma tabela do DynamoDB, o stream captura a alteração e aciona a função Lambda.
2. **AWS Lambda**: Processa os eventos do DynamoDB Stream e prepara uma mensagem para ser enviada.
3. **SNS (Simple Notification Service)**: A Lambda envia uma mensagem para o SNS, que pode acionar outras funções ou notificar usuários/serviços.

## Fluxo

1. Uma modificação é feita em uma tabela DynamoDB (ex: inserção, atualização, exclusão).
2. O DynamoDB Stream captura essa modificação e envia o evento para a função Lambda.
3. A função Lambda processa o evento e extrai os dados relevantes.
4. A Lambda envia a mensagem para um tópico SNS.
5. Outros sistemas podem se inscrever no SNS para receber notificações sobre essa mudança.

## Pré-requisitos

- **AWS Account**: Uma conta da AWS para acessar os serviços como Lambda, DynamoDB, SNS e IAM.
- **AWS CLI** ou **Terraform**: Para fazer o deploy da função Lambda e os recursos necessários.
- **IAM Role**: A função Lambda precisa de permissões para ler do DynamoDB Stream e publicar no SNS.

## Como usar

1. **Clone este repositório**:

    ```bash
    git clone https://github.com/seu-usuario/dynamo-lambda-sns.git
    cd dynamo-lambda-sns
    ```

2. **Instalar dependências** (se houver alguma dependência Python):

    ```bash
    pip install -r requirements.txt
    ```

3. **Configuração de recursos (DynamoDB, SNS e Lambda)**:
   
   Você pode utilizar o **Terraform** ou a AWS Console para criar os recursos necessários:
   
   - **DynamoDB Stream**: Habilite o stream para a tabela do DynamoDB.
   - **SNS Topic**: Crie um tópico SNS para enviar mensagens.
   - **IAM Role**: Crie uma role para a Lambda com permissões para acessar o DynamoDB Stream e o SNS.
   - **Lambda**: Configure a função Lambda para ser acionada pelo DynamoDB Stream.

4. **Deploy da função Lambda**:
   
   Para publicar os recursos na AWS, você pode usar o **Terraform** ou fazer isso diretamente pela AWS Console.

5. **Testar**:

    - Faça uma modificação em sua tabela do DynamoDB (inserção, atualização ou exclusão).
    - Verifique se a função Lambda é acionada e se a mensagem foi enviada para o SNS.
    - Inscreva-se no SNS para receber as notificações.

## Exemplo de código da Lambda

```python
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
        
        # Publicar a mensagem no SNS
        response = sns_client.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps(data),
            Subject='DynamoDB Stream Event'
        )
        
        print(f"Mensagem enviada para o SNS: {response}")
    return {
        'statusCode': 200,
        'body': json.dumps('Processamento concluído.')
    }
