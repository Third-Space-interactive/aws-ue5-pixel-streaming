import boto3

from json import dumps
from os import environ
from time import sleep


ec2 = boto3.client('ec2')
cloudwatch = boto3.client('cloudwatch')


def lambda_handler(event, context):
  # Launch an instance using the specified Launch Template
  response = ec2.run_instances(
    LaunchTemplate={
      'LaunchTemplateName': environ['LaunchTemplateName'],
      'Version': '$Latest'
    },
    SubnetId = environ['SubnetId'],
    MinCount = 1,
    MaxCount = 1
  )

  # Add a Name tag to the instance
  ec2.create_tags(
    Resources = [response['Instances'][0]['InstanceId']],
    Tags = [
      {
        'Key': 'Name',
        'Value': 'ue5-pixel-streaming-instance'
      }
    ]
  )

  # Create an alarm to terminate the instance if NetworkIn < 1MB/s for 5 minutes
  cloudwatch.put_metric_alarm(
    AlarmName = f"NetworkIn-{response['Instances'][0]['InstanceId']}-Alarm",
    Namespace = 'AWS/EC2',
    MetricName = 'NetworkIn',
    Statistic = 'Average',
    Period = 60,
    EvaluationPeriods = 5,
    Threshold = 1000,
    ComparisonOperator = 'LessThanThreshold',
    ActionsEnabled = True,
    AlarmActions = [f'arn:aws:automate:{environ["Region"]}:ec2:terminate'],
    Dimensions = [
      {
        'Name': 'InstanceId',
        'Value': response['Instances'][0]['InstanceId']
      }
    ]
  )

  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    sleep(5)

    # Get the instance's public IP address
    instance = ec2.describe_instances(
      InstanceIds = [response['Instances'][0]['InstanceId']]
    )

    return {
      'statusCode': 200,
      'headers' : {
        'Access-Control-Allow-Origin' : f"https://{environ['CloudFrontDomain']}",
        'Access-Control-Allow-Headers': '*',
      },
      'body': dumps({'Ip': instance['Reservations'][0]['Instances'][0]['PublicIpAddress']})
    }
  else:
    return { 
      'statusCode': 500,
      'headers' : {
        'Access-Control-Allow-Origin' : f"https://{environ['CloudFrontDomain']}",
        'Access-Control-Allow-Headers': '*',
      } 
    }
