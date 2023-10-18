#!/bin/bash

TERRAFORM_DIR="path/to/terraform/files"

cd $TERRAFORM_DIR
terraform init
terraform apply -auto-approve

echo "Terraform configuration has been applied."