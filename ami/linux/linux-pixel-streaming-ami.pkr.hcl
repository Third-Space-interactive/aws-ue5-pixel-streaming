packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

data "amazon-ami" "ami_id" {
  filters = {
    name                = "ubuntu-noble-24.04-*"
    architecture        = var.architecture
    virtualization-type = "hvm"
    root-device-type    = "ebs"
  }

  owners      = ["amazon"]
  most_recent = true
}

source "amazon-ebs" "pixel-streaming" {
  ami_name      = "pixel-streaming-ami-${local.timestamp}"
  instance_type = "g4dn.xlarge"
  region        = "eu-central-1"
  source_ami    = data.amazon-ami.ami_id.id
  ssh_username  = "ec2-user"

  ami_block_device_mappings {
    delete_on_termination = "true"
    device_name           = "/dev/xvda"
    volume_size           = "250"
  }

  tags = {
    CreationDt = "${timestamp()}"
    Name       = "pixel-streaming-ami-${local.timestamp}"
  }
}

build {
  sources = ["source.amazon-ebs.pixel-streaming"]

  provisioner "file" {
    destination = "/"
    source      = "../ue5-pixel-streaming-project"
  }

  provisioner "shell" {
    inline = [
      "sudo yum -y install curl",
      "sudo yum -y install git",
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash",
      "nvm install 20",
      "git clone https://github.com/EpicGamesExt/PixelStreamingInfrastructure.git"
    ]
    pause_before = "4s"
  }
}
