# Self-Healing Infrastructure with Terraform and AWS

This project provides a framework for creating a self-healing infrastructure on AWS using Terraform, Lambda functions, CloudWatch Events, and Systems Manager (SSM) Automation documents. When specific health checks fail, remediation steps are automatically initiated to resolve the issues without human intervention.

## Overview

- **AWS Lambda**: Executes health checks on an EC2 instance. If it detects an unhealthy resource or service, it triggers an SSM Automation document for remediation.
- **CloudWatch Event Rule**: Periodically invokes the health check Lambda function (e.g., every 5 minutes).
- **SSM Automation Document**: Defines a sequence of remediation steps. In this example, the steps involve stopping, waiting, and restarting an EC2 instance.

## Prerequisites

1. AWS CLI installed and configured with appropriate permissions.
2. Terraform installed.
3. IAM permissions to manage Lambda, CloudWatch Events, SSM, and EC2 resources.
4. A ZIP file containing the Lambda function code.

## Setup

### 1. Deploying Terraform Configuration

Run the provided script to initialize and apply the Terraform configuration:

```bash
chmod +x deploy_terraform.sh
./deploy_terraform.sh
```

### 2. Deploying the Lambda Function

Navigate to the directory containing the Lambda function, package it, and deploy using the provided script:

```bash
chmod +x deploy_lambda.sh
./deploy_lambda.sh
```

## Health Check

The Lambda function performs the following checks:

1. Ensures that the EC2 instance is in the `running` state.
2. Evaluates the EC2 instance's CPU utilization over the past 5 minutes. If the average CPU utilization exceeds 80%, it's considered unhealthy.

You can manually trigger the health check using:

```bash
chmod +x health_check.sh
./health_check.sh
```

## Remediation Steps

The SSM Automation document currently has the following steps for remediation:

1. Stop the specified EC2 instance.
2. Wait for the instance to fully stop.
3. Restart the EC2 instance.

The instance ID and other parameters can be customized in the `main.tf` Terraform configuration.

## Customization

1. **Lambda Health Checks**: Customize the health checks in the Lambda function (`lambda_function.py`) based on your specific infrastructure needs.
2. **Remediation Steps**: Adjust the `mainSteps` section in the SSM document (within the Terraform configuration) to better fit your requirements.

## Permissions

Make sure IAM roles and policies grant appropriate permissions:

- The Lambda function should have permissions to invoke the SSM Automation document and to fetch metrics from CloudWatch.
- The SSM Automation execution role must have permissions to perform the specified remediation actions (e.g., stopping and restarting EC2 instances).
