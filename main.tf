provider "aws" {
  region = "us-west-1"
}

resource "aws_lambda_function" "health_check_lambda" {
  function_name = "HealthCheckLambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "path/to/lambda/files/lambda.zip"
  source_code_hash = filebase64sha256("path/to/lambda/files/lambda.zip")

  role = aws_iam_role.lambda_execution_role.arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "health_check_trigger" {
  name                = "health-check-trigger"
  description         = "Triggers the health check Lambda every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "health_check_lambda_target" {
  rule      = aws_cloudwatch_event_rule.health_check_trigger.name
  target_id = "HealthCheckLambdaTarget"
  arn       = aws_lambda_function.health_check_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.health_check_trigger.arn
}

resource "aws_ssm_document" "remediation_document" {
  name            = "YourSSMDocumentName"
  document_type   = "Automation"

  content = jsonencode({
    schemaVersion = "0.3",
    description   = "Remediation steps for EC2 instance",
    mainSteps     = [
      // Your remediation steps go here
    ]
  })
}