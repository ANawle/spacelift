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
  role_arn                       = data.aws_iam_role.spacelift_role.arn
  generate_credentials_in_worker = false
}

# Fetch the existing IAM Role
data "aws_iam_role" "spacelift_role" {
  name = "Spacelift"
}

# ✅ Update the Assume Role Policy of the existing IAM Role
resource "aws_iam_role_policy" "spacelift_trust_policy" {
  role = data.aws_iam_role.spacelift_role.name
  name = "SpaceliftTrustPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
