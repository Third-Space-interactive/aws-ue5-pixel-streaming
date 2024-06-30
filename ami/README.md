# Create the Pixel Streaming AMI

This brief tutorial was made possible with the help of the team at  [@TensorWorks](https://github.com/TensorWorks) and their [guide](https://github.com/TensorWorks/PixelStreamingCloudGuide) about Pixel Streaming in the cloud.

## 1 - Creating and Packaging a Pixel Streaming Project in Unreal Engine

To start a Pixel Streaming project in Unreal Engine, I recommend following this [tutorial](https://dev.epicgames.com/documentation/en-us/unreal-engine/getting-started-with-pixel-streaming-in-unreal-engine?application_version=5.3#1-prepareyourunrealengineapplication) from Epic Games. It will guide you in establishing the foundation for your own project.

**⚠️ Please remember to package your project for Linux instead of Windows.**

## 2 - Launching your instance
This is likely the simplest step. You need to launch an EC2 instance with the following configuration:
- <ins>Amazon Machine Image (AMI):</ins> `Ubuntu Server 22.04 LTS (HVM), SSD Volume Type`
- <ins>Instance Type:</ins> `g4dn.xlarge` or higher
- <ins>Storage:</ins> `30Gb gp2`
- <ins>IAM Instance Profile:</ins> Create one with `AmazonS3ReadOnlyAccess` policy

## 3 - Installing the Nvidia Drivers (GRID)
1. First, run the following commands:
```
sudo apt-get update -y 
sudo apt-get install -y gcc
sudo apt-get install -y make
sudo apt-get upgrade -y linux-aws
sudo reboot
```

2. After the reboot, run the following commands:
```
sudo apt-get install -y gcc make linux-headers-$(uname -r)
cat << EOF | sudo tee --append /etc/modprobe.d/blacklist.conf
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF
echo 'GRUB_CMDLINE_LINUX="rdblacklist=nouveau"' | sudo tee --append /etc/default/grub
sudo update-grub
sudo apt-get install -y awscli
aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ .
chmod +x NVIDIA-Linux-x86_64*.run
sudo /bin/sh ./NVIDIA-Linux-x86_64*.run
sudo touch /etc/modprobe.d/nvidia.conf
echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee --append /etc/modprobe.d/nvidia.conf
sudo reboot
```

## 4 - Installing Vulkan and Pulse Audio
1. For Vulkan, run the following commands:
```
wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo apt-key add -
sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-focal.list http://packages.lunarg.com/vulkan/lunarg-vulkan-focal.list
sudo apt-get update -y
sudo apt-get install -y vulkan-utils
```
2. For Pulse Audio, run the following command: `sudo apt-get install -y pulseaudio`

## 5 - Creating the AMI
1. Before creating your AMI, clean the `get_ps_servers.sh` script *(located in the `<project_folder>/Linux/<project_name/Samples/PixelStreaming/WebServers` folder)* with this command: `sed 's//r$//' get_ps_server.sh > get_ps_server.sh`. Afterward, run the `get_ps_server.sh` script.
2. To create an AMI, follow this [tutorial](https://docs.aws.amazon.com/toolkit-for-visual-studio/latest/user-guide/tkv-create-ami-from-instance.html). **⚠️ Ensure you name it using the following pattern::** `pixel-streaming-ami-linux-...`.

## 6 - Run your Pixel Streaming App
1. Run: `<project_folder>/Linux/<project_name>/Samples/PixelStreaming/WebServers/SignallingWebServer/platform_scripts/bash/Start_WithTURN_SignallingServer.sh &`
2. Then run: `<project_folder>/Linux/<project_name>.sh -PixelStreamingIP=127.0.0.1 -PixelStreamingPort=8888 -RenderOffscreen -ResX=1920 -ResY=1080 -ForceRes &`
3. Connect to your instance public IP with a web browser and enjoy!
