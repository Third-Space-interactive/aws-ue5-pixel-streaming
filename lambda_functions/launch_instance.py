import boto3
import os
import json


ec2 = boto3.client('ec2')


def lambda_handler(event, context):
    response = ec2.run_instances(
      LaunchTemplate={
        'LaunchTemplateName': os.environ("LaunchTemplateName")
      },
      MinCount = 1,
      MaxCount = 1
    )

  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    return json.dumps({"status": "success", "message": "Instance created successfully", "publicIp": response['Instances'][0]['PublicIpAddress']})
