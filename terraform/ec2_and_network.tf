locals {
  vpc_cidr       = "10.1.0.0/16"
  allowed_ports  = [22, 80]
  user_data_path = "${abspath(path.cwd)}/../ami/userdata.sh"
}

# Network configuration
resource "aws_vpc" "main_vpc" {
  enable_dns_hostnames = true
  enable_dns_support   = true
  cidr_block           = local.vpc_cidr

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_subnet" "public_subnet" {
  count = length(local.availabilty_zones)

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = cidrsubnet(local.vpc_cidr, 4, count.index)
  availability_zone       = local.availabilty_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(local.availabilty_zones)

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# EC2 Launch Template
resource "aws_security_group" "pixel_streaming_sg" {
  name   = "ue5-pixel-streaming"
  vpc_id = aws_vpc.main_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  dynamic "ingress" {
    for_each = local.allowed_ports

    content {
      cidr_blocks = ["${var.my_ip}/32"]
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
    }
  }
}

data "aws_ami" "pixel_streaming_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["pixel-streaming-ami-linux-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "pixel_streaming_instance" {
  name_prefix            = "ue5-pixel-stream-"
  image_id               = data.aws_ami.pixel_streaming_ami.id
  instance_type          = "g4dn.xlarge"
  vpc_security_group_ids = [aws_security_group.pixel_streaming_sg.id]
  user_data              = filebase64(local.user_data_path)

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  tags = {
    Name = "ue5-pixel-stream"
  }
}
