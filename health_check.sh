#!/bin/bash

LAMBDA_FUNCTION_NAME="HealthCheckLambda"

aws lambda invoke \
  --function-name $LAMBDA_FUNCTION_NAME \
  --payload '{}' \
  /dev/stdout