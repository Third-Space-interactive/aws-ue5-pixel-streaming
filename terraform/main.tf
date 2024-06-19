###############
# Frontend (S3/Cloudfront)
###############
module "frontend" {
  source = "./modules/s3_web"

  bucket_name = "aws-ue5-pixel-streaming-frontend"

  cloudfront_config = {
    origin_id   = "frontend"
    description = "Cloudfront Distribution for the frontend"
  }
}

# Module 2:
# - Create the Lambda function (to launch an instance)
# - API Gateway (REST API)
# - AGW Endpoint and Resource for the Lambda

# Module 3:
# - EC2 Launch Template

# Module 4:
# - Create the other Lambda function (to terminate an instance)
# - Create a Cloudwatch alarms + a rule to trigger the Lambda
