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
  # Uses Spacelift API credentials (set via environment variables)
}

provider "aws" {
  region = "us-east-1" # Change as needed
}

# 🔹 Input Variables for AWS Account and Stack Name
variable "aws_account_id" {
  description = "AWS Account ID for integration"
  type        = string
}

variable "stack_name" {
  description = "Spacelift Stack Name"
  type        = string
}

# 🔹 Create a Spacelift Stack
resource "spacelift_stack" "stack" {
  name         = var.stack_name
  repository   = "your-repo-name"  # Change this to your repo
  branch       = "main"
  description  = "Spacelift Stack for ${var.stack_name}"
}

# 🔹 Create an AWS Integration in Spacelift
resource "spacelift_aws_integration" "aws_integration" {
  name                           = "aws-integration-${var.aws_account_id}"
  role_arn                       = aws_iam_role.spacelift_role.arn
  generate_credentials_in_worker = false
  stack_id                       = spacelift_stack.stack.id  # Attaches to Stack
}

# 🔹 IAM Role for Spacelift (Already Exists, Just Updating Trust Policy)
resource "aws_iam_role" "spacelift_role" {
  name = "Spacelift"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Principal": { "AWS": "094693243018" }, # Spacelift AWS Account ID
        "Action": "sts:AssumeRole",
        "Condition": {
          "StringEquals": {
            "sts:ExternalId": spacelift_stack.stack.id # Fetching Stack ID Automatically
          }
        }
      }
    ]
  })
}
