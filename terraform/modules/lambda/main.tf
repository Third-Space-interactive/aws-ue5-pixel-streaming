###############
# IAM Role
###############
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name                = "${var.name}lambda-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = concat(["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"], var.lambda.policies)
}

###############
# Lambda
###############
data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.lambda.path
  output_path = replace(var.lambda.path, ".py", ".zip")
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.11"
  handler = var.lambda.handler
  timeout = var.lambda.timeout

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  dynamic "environment" {
    for_each = length(var.lambda.environment) > 0 ? [""] : [] # One block if var.environment is not empty
    content {
      variables = var.lambda.environment
    }
  }
}
