# Install the required drivers
1. Run the following script:
```
sudo apt-get update -y
sudo apt-get install -y gcc
sudo apt-get install -y make
sudo apt-get upgrade -y linux-aws
sudo reboot
```
2. After reboot, run the following script:
```
sudo apt-get install -y gcc make linux-headers-$(uname -r)
cat << EOF | sudo tee --append /etc/modprobe.d/blacklist.conf
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF
cat "GRUB_CMDLINE_LINUX="rdblacklist=nouveau" | sudo tee --append /etc/default/grub
sudo update-grub
sudo apt-get install -y awscli
aws s3 cp --recursive s3://ec2-linux-nvidia-drivers/latest/ .
chmod +x NVIDIA-Linux-x86_64*.run
sudo /bin/sh ./NVIDIA-Linux-x86_64*.run
sudo touch /etc/modprobe.d/nvidia.conf
echo "options nvidia NVreg_EnableGpuFirmware=0" | sudo tee --append /etc/modprobe.d/nvidia.conf
sudo reboot
```

# Install Vulkan and Pulse Audio
1. For Vulkan, run the following script:
```
wget -qO - http://packages.lunarg.com/lunarg-signing-key-pub.asc | sudo apt-key add -
sudo wget -qO /etc/apt/sources.list.d/lunarg-vulkan-focal.list http://packages.lunarg.com/vulkan/lunarg-vulkan-focal.list
sudo apt-get update -y
sudo apt-get install -y vulkan-utils
```
2. For Pulse Audio, run the following: `sudo apt-get install -y pulseaudio`