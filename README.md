# AWS/UE5 Pixel Streaming

All of this is not suitable for production, it's just a proof of concept.

## How it works?
1. On the frontend you request for an instance
2. The request is forwarded to a Lambda trough an API Gateway
3. The Lambda launch an EC2 instance and answer with the public IP of the instance
4. The frontend show the IP
5. Pixel Streaming! 🎉
6. A Lambda function is triggered when the NetworkIn of an instance is 0 for 5 minutes and terminate the instance

## How to?
1. Create an AMI following the tutorial using Packer (`cd ami && packer build .`)
2. Configure terraform (add a profile or credentials in `/terraform/providers.tf`)
3. Deploy terraform code (`cd terraform && terraform init && terraform apply`) and copy your API URL from the Output
4. Click on the frontend URL from the Output
5. Configure the frontend with the API URL
6. Request an instance
7. Wait for the public IP
8. Click on the public IP and enjoy the Pixel Streaming!