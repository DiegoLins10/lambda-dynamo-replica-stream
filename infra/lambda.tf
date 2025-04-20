provider "aws" {
  region = "us-east-1"  # ou sa-east-1, se preferir São Paulo
}

# Recuperando o segredo do ARN do DynamoDB Stream
data "aws_secretsmanager_secret" "dynamodb_stream_arn_secret" {
  name = "dynamodb_stream_arn"  # Nome do seu segredo no Secrets Manager
}

data "aws_secretsmanager_secret_version" "dynamodb_stream_arn_version" {
  secret_id = data.aws_secretsmanager_secret.dynamodb_stream_arn_secret.id
}

# Criando o IAM Role para Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  # Política Inline para DynamoDB Streams
  inline_policy {
    name   = "dynamodb-streams-policy-v1"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "dynamodb:DescribeStream",
            "dynamodb:GetShardIterator",
            "dynamodb:GetRecords",
            "dynamodb:ListStreams"
          ]
          Resource = "*"
        }
      ]
    })
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# Attachando a política básica de execução do Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Criando a função Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../app/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "hello_lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Mapeando o stream do DynamoDB com a função Lambda
resource "aws_lambda_event_source_mapping" "dynamodb_stream_trigger" {
  count             = length(data.aws_lambda_event_source_mapping.existing_mapping.ids) == 0 ? 1 : 0
  event_source_arn  = jsondecode(data.aws_secretsmanager_secret_version.dynamodb_stream_arn_version.secret_string)["dynamodb_stream_arn"]
  function_name     = aws_lambda_function.hello_lambda.arn
  starting_position = "LATEST"
  batch_size        = 1
}

data "aws_lambda_event_source_mapping" "existing_mapping" {
  event_source_arn = jsondecode(data.aws_secretsmanager_secret_version.dynamodb_stream_arn_version.secret_string)["dynamodb_stream_arn"]
}