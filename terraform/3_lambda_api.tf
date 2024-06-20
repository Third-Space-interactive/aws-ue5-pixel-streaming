locals {
  launch_instance_lambda_path = "${abspath(path.cwd)}../lambda_functions/launch_instance.py"
}

###############
# API Gateway
###############
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
  uri                     = module.lambda_api.invoke_arn

  depends_on = [aws_api_gateway_method.create_instance_endpoint]
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  stage_name    = "api"

  lifecycle {
    ignore_changes = [deployment_id]
  }

  depends_on = [module.lambda_api]
}

###############
# Lambda
###############
data "aws_iam_policy_document" "lambda_api_role_policy" {
  statement {
    actions = [
      "ec2:RunInstances",
      "ec2:DescribeInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_api_role_policy" {
  name   = "launch-instance-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_api_role_policy.json
}

module "lambda_api" {
  source = "./modules/lambda"

  name = "launch-instance"
  lambda = {
    path     = local.launch_instance_lambda_path
    handler  = "launch_instance.lambda_handler"
    policies = [aws_iam_policy.lambda_api_role_policy.arn]
    environment = {
      LaunchTemplateName = aws_launch_template.pixel_streaming_instance.arn
      SubnetId           = aws_subnet.public_subnet[0].id
    }
  }
}

###############
# Lambda Permission
###############
resource "aws_lambda_permission" "allow_api_gateway_to_invoke_lambda" {
  statement_id  = "AllowApiGatewayInvocation"
  action        = "lambda:InvokeFunction"
  function_name = "launch-instance"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/${aws_api_gateway_method.create_instance_endpoint.http_method}/${aws_api_gateway_resource.create_instance.path_part}"
}
