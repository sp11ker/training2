###############################
# Provider
###############################
provider "aws" {
  region = "us-east-1"
}

###############################
# 1. VPC
###############################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
  }
}

###############################
# 2. Subnet
###############################
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-subnet"
  }
}

###############################
# 3. Internet Gateway
###############################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Terraform-IGW"
  }
}

###############################
# 4. Route Table
###############################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terraform-Public-RouteTable"
  }
}

###############################
# 5. Route Table Association
###############################
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

###############################
# 6. Security Group (Allow SSH)
###############################
resource "aws_security_group" "ssh" {
  name        = "my-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-SSH-SG"
  }
}

###############################
# 7. Generate SSH Key Pair (TLS)
###############################
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

###############################
# 8. AWS Key Pair from TLS
###############################
resource "aws_key_pair" "my_key" {
  key_name   = "my-keypair"
  public_key = tls_private_key.example.public_key_openssh
}

###############################
# 9. EC2 Instance
###############################
resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "ec2-web"
  }
}

###############################
# 10. Random suffix for bucket
###############################
resource "random_id" "suffix" {
  byte_length = 4
}

###############################
# 11. S3 Bucket for VPC Flow Logs (force us-east-1)
###############################
resource "aws_s3_bucket" "flow_logs_bucket" {
  bucket = "my-flow-logs-bucket-${random_id.suffix.hex}"
  tags = {
    Name = "Terraform-FlowLogs-Bucket"
  }
}

###############################
# 12. Current AWS Account
###############################
data "aws_caller_identity" "current" {}

###############################
# 13. Bucket Policy for Flow Logs
###############################

resource "aws_s3_bucket_policy" "flow_logs_policy" {
  bucket = aws_s3_bucket.flow_logs_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. Allow VPC Flow Logs delivery
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.flow_logs_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "AWSLogDeliveryAclCheck"
        Effect    = "Allow"
        Principal = { Service = "vpc-flow-logs.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.flow_logs_bucket.arn
      },

      # 2. Allow all IAM users/roles in your account to read/list
      {
        Sid       = "AllowAccountWideRead"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "s3:GetObject",
