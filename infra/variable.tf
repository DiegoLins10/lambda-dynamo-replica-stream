variable "lambda_function_name" {
  default = "lambda-dynamo-replica-stream"
}

variable "dynamodb_stream_arn" {
  description = "ARN do stream do DynamoDB"
  type        = string
  sensitive   = true
}
