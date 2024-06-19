import boto3

from json import dumps
from os import environ
from time import sleep


ec2 = boto3.client('ec2')


def lambda_handler(event, context):
  response = ec2.run_instances(
    LaunchTemplate={
      'LaunchTemplateName': environ['LaunchTemplateName'],
      'Version': '$Latest'
    },
    SubnetId = environ['SubnetId'],
    MinCount = 1,
    MaxCount = 1
  )

  if response['ResponseMetadata']['HTTPStatusCode'] == 200:
    sleep(15)

    instance = ec2.describe_instances(
      InstanceIds = [response['Instances'][0]['InstanceId']]
    )

    return {
      'statusCode': 200,
      'headers' : {
        'Access-Control-Allow-Origin' : '*',
        'Access-Control-Allow-Headers': '*',
      },
      'body': dumps({'Ip': instance['Reservations'][0]['Instances'][0]['PublicIpAddress']})
    }
  else:
    return { 'statusCode': 500 }
