# AWS/UE5 Pixel Streaming

All of this is for testing purposes and shouldn't be deployed in production!

## Need...
Infra:
- [X] S3 Bucket and Cloudfront Distribution for the frontend
- [X] API Gateway and a Lambda function _(to launch an EC2 instance)_
- [X] EC2 Instance _(g4dn.xlarge)_ with a custom AMI _(with the UE5 executable)_
- [ ] CloudWatch Alarm + Lambda _(when NetworkIn = 0 for 5 minutes on an instance, a Lambda is triggered to terminate the instance)_

Other:
- [X] Basic frontend (just a button and something to call the API and give back the instance IP)

## How it works?
1. On the frontend you request for an instance
2. The request is forwarded to a Lambda trough an API Gateway
3. The Lambda launch an EC2 instance and answer with the IP through the API Gateway
4. The frontend show the IP
5. Pixel Streaming! 🎉

## How to?
1. Create an AMI following the tutorial (TODO)
2. Deploy terraform code
3. Enjoy