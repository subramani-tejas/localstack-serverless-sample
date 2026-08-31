#!/bin/bash
set -e

echo "===== Creating DynamoDB Table =====tjs"
awslocal dynamodb create-table \
  --table-name Messages \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

echo "===== Zipping & Deploying Lambdas =====tjs"
cd /tmp/src
zip -q -r /tmp/handler.zip handler.py

awslocal lambda create-function \
  --function-name messages-api \
  --runtime python3.9 \
  --handler handler.handler \
  --zip-file fileb:///tmp/handler.zip \
  --role arn:aws:iam::000000000000:role/lambda-role \
  --environment Variables={TABLE_NAME=Messages}

awslocal lambda wait function-active --function-name messages-api

# why you don't need api-gw
awslocal lambda create-function-url-config \
  --function-name messages-api \
  --auth-type NONE

LAMBDA_URL=$(awslocal lambda list-function-url-configs \
  --function-name messages-api \
  --query 'FunctionUrlConfigs[0].FunctionUrl' \
  --output text)
echo $LAMBDA_URL