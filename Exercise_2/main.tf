terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.region
}


data "archive_file" "greet_lambda" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = var.output_path
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "greet_lambda" {
  filename      = data.archive_file.greet_lambda.output_path
  function_name = var.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.lambda_handler"

  runtime = "python3.9"

  environment {
    variables = {
      greeting = var.function_name
    }
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs_policy,
    aws_cloudwatch_log_group.example,
  ]
}

data "aws_iam_policy_document" "lambda_logs_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
}

resource "aws_iam_policy" "lambda_logs_policy" {
  name        = "lambda_logs_policy"
  path        = "/"
  description = "Lambda loging IAM policy"
  policy      = data.aws_iam_policy_document.lambda_logs_policy.json
}
