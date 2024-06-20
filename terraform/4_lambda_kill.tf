locals {
  kill_instance_lambda_path = "${abspath(path.cwd)}../lambda_functions/kill_instance.py"
}

###############
# Lambda
###############
data "aws_iam_policy_document" "lambda_kill_role_policy" {
  statement {
    actions = [
      "ec2:TerminateInstances"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_kill_role_policy" {
  name   = "kill-instance-lambda-policy"
  policy = data.aws_iam_policy_document.lambda_kill_role_policy.json
}

module "lambda_kill" {
  source = "./modules/lambda"

  name = "kill-instance-lambda"
  lambda = {
    path     = local.kill_instance_lambda_path
    handler  = "kill_instance.lambda_handler"
    policies = [aws_iam_policy.lambda_kill_role_policy.arn]
  }
}

###############
# Cloudwatch Alarm for EC2
###############
resource "aws_cloudwatch_metric_alarm" "ec2_networkin_alarm" {
  alarm_name = "ec2-networkin-alarm"

  namespace           = "AWS/EC2"
  metric_name         = "NetworkIn"
  evaluation_periods  = 1
  period              = 60 * 5
  comparison_operator = "LessThanThreshold"
  statistic           = "Average"
  threshold           = 1000
  unit                = "Bytes"

  alarm_actions = [module.lambda_kill.arn]
}

###############
# Lambda Permission
###############
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "kill-instance-lambda"
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.ec2_networkin_alarm.arn
}