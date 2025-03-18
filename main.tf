terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "spacelift" {
  # Spacelift API credentials (configured via environment variables)
}

provider "aws" {
  region = "us-east-1" # Change as needed
}

# Fetch AWS Account ID from input
variable "aws_account_id" {
  description = "AWS Account ID for integration"
  type        = string
}

# Fetch Stack Name (used as stack_id)
variable "stack_name" {
  description = "Spacelift Stack Name"
  type        = string
}

# Create an AWS integration in Spacelift
resource "spacelift_aws_integration" "aws_integration" {
  name                           = "aws-integration-${var.aws_account_id}"
  role_arn                       = aws_iam_role.spacelift_role.arn
  generate_credentials_in_worker = false
}

# Update the trust policy of an existing IAM Role named "Spacelift"
resource "aws_iam_role" "spacelift_role" {
  name = "Spacelift"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
  "Action": "sts:AssumeRole",
  "Condition": {
    "StringEquals": {
      "sts:ExternalId": "zuplon@01JPMH1QMWAHC348V7H1M8XBV9@avinash_prompt3-2@write"
    }
  },
  "Effect": "Allow",
  "Principal": {
    "AWS": "324880187172/role/Spacelift"
  }
}
    ]
  })

  lifecycle {
    ignore_changes = [name] # Prevent accidental recreation
  }
}
