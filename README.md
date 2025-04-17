# UE5 Pixel Streaming powered by AWS
<p align="center">
  <img src="https://github.com/louis-fiori/aws-ue5-pixel-streaming/blob/main/assets/pixel_streaming_gif.gif?raw=true"/>
</p>

**⚠️ All of this is not suitable for production, it's just a proof of concept.**

**If you have any problems, open an issue and I'll try my best to fix it.**

## 📝 Medium Article

Article availaible [here](https://medium.com/@louis-fiori/unreal-engine-pixel-streaming-on-aws-building-a-homemade-cloud-gaming-prototype-41b90c72c5ce)

## ➡️ How to deploy
1. **Create an AMI** following [this guide](https://github.com/louis-fiori/aws-ue5-pixel-streaming/blob/main/ami/README.md)
2. **Configure terraform** by adding a profile or credentials in `/terraform/providers.tf`
3. **Deploy on AWS using terraform**:
    - Navigate to the Terraform directory: `cd terraform`
    - Initialize Terraform: `terraform init`
    - Apply the Terraform configuration: `terraform apply`
4. **Copy your API URL** from the Terraform output
5. **Open the frontend URL** from the Terraform output
6. **Configure the frontend** by clicking on `API Configuration` and enter your API URL
7. **Request an instance** by clicking on `Request an instance`
8. **Wait for the public IP** of your launched instance
9. **Access the instance** by clicking on the public IP displayed by the frontend and enjoy!

<p align="center">
  <img src="https://github.com/louis-fiori/aws-ue5-pixel-streaming/blob/main/assets/frontend_capture_1.png?raw=true"/>
</p>
