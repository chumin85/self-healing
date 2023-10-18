#!/bin/bash

LAMBDA_FUNCTION_NAME="HealthCheckLambda"
ZIP_FILE_NAME="lambda.zip"
LAMBDA_FILE_PATH="path/to/lambda/files/lambda_function.py"

cd "$(dirname "$LAMBDA_FILE_PATH")"
zip $ZIP_FILE_NAME lambda_function.py

aws lambda update-function-code \
  --function-name $LAMBDA_FUNCTION_NAME \
  --zip-file fileb://$ZIP_FILE_NAME

echo "Lambda function $LAMBDA_FUNCTION_NAME has been updated."