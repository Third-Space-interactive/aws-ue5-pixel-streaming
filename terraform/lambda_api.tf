locals {
  launch_instance_lambda_path = "${abspath(path.cwd)}/lambda_functions/launch_instance.py"
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name              = "backend"
  put_rest_api_mode = "merge"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "create_instance" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "create-instance"
}

resource "aws_api_gateway_method" "create_instance_endpoint" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.create_instance.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_instance_endpoint" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.create_instance.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn

  depends_on = [aws_api_gateway_method.create_instance_endpoint]
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.create_instance_endpoint]
}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "api"

  lifecycle {
    ignore_changes = [deployment_id]
  }

  depends_on = [aws_lambda_function.lambda]
}

# Lambda IAM Role
data "aws_iam_policy_document" "lambda_api_role_policy" {
  statement {
    actions = [
      "ec2:RunInstances",
      "ec2:DescribeInstances",
      "ec2:CreateTags",
      "cloudwatch:PutMetricAlarm",
      "iam:CreateServiceLinkedRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_api_role_policy" {
  name   = "launch-instance-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_api_role_policy.json
}

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
  name               = "launch-instance-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.lambda_api_role_policy.arn
  ]
}

# Lambda Function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = local.launch_instance_lambda_path
  output_path = replace(local.launch_instance_lambda_path, ".py", ".zip")
}

resource "aws_lambda_function" "lambda" {
  function_name = "launch-instance"
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.11"
  handler = "launch_instance.lambda_handler"
  timeout = 500

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      LaunchTemplateName = aws_launch_template.pixel_streaming_instance.name
      SubnetId           = aws_subnet.public_subnet[0].id
      CloudFrontDomain   = aws_cloudfront_distribution.cloudfront_distribution.domain_name
      Region             = var.region
    }
  }
}

# Lambda Permission
resource "aws_lambda_permission" "allow_api_gateway_to_invoke_lambda" {
  statement_id  = "AllowApiGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.create_instance_endpoint.http_method}/${aws_api_gateway_resource.create_instance.path_part}"
}
