import boto3


ec2 = boto3.client('ec2')


def lambda_handler(event, context):
    ec2.terminate_instances(
        InstanceIds = [event['detail']['instance-id']]
    )
    
    return { 'statusCode': 200 }