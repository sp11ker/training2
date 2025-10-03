provider "aws" {
  region = "us-east-1"
}

###############################
# 1. Shared Key Pair
###############################
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "shared_key" {
  key_name   = "my-keypair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/my-keypair.pem"
  file_permission = "0600"
}

###############################
# 2. Locals for configuration
###############################
locals {
  environments = ["staging", "dev", "prod"]

  ec2_instances = {
    "monitoring-staging-jumpbox" = {
      app        = "monitoring"
      env        = "staging"
      role       = "jumpbox"
      compliance = "medium"
    },
    "finance-dev-web" = {
      app        = "finance"
      env        = "dev"
      role       = "web"
      compliance = "low"
    },
    "finance-dev-proc" = {
      app        = "finance"
      env        = "dev"
      role       = "proc"
      compliance = "low"
    },
    "finance-dev-db" = {
      app        = "finance"
      env        = "dev"
      role       = "db"
      compliance = "low"
    },
    "crm-dev-node" = {
      app        = "crm"
      env        = "dev"
      role       = "node"
      compliance = "low"
    },
    "finance-prod-web" = {
      app        = "finance"
      env        = "prod"
      role       = "web"
      compliance = "high"
    },
    "finance-prod-proc" = {
      app        = "finance"
      env        = "prod"
      role       = "proc"
      compliance = "high"
    },
    "finance-prod-db" = {
      app        = "finance"
      env        = "prod"
      role       = "db"
      compliance = "high"
    },
    "crm-prod-node" = {
      app        = "crm"
      env        = "prod"
      role       = "node"
      compliance = "high"
    }
  }

  # Mapping env to resources
  vpc_map = {
    staging = aws_vpc.staging.id,
    dev     = aws_vpc.dev.id,
    prod    = aws_vpc.prod.id
  }

  subnet_map = {
    staging = aws_subnet.staging.id,
    dev     = aws_subnet.dev.id,
    prod    = aws_subnet.prod.id
  }

  sg_map = {
    staging = aws_security_group.staging.id,
    dev     = aws_security_group.dev.id,
    prod    = aws_security_group.prod.id
  }
}

###############################
# 3. Networking: VPC, Subnet, IGW, RT, SG
###############################

# VPCs
resource "aws_vpc" "staging" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "staging-vpc"
    Env     = "staging"
    Company = "acme"
  }
}

resource "aws_vpc" "dev" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name    = "dev-vpc"
    Env     = "dev"
    Company = "acme"
  }
}

resource "aws_vpc" "prod" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name    = "prod-vpc"
    Env     = "prod"
    Company = "acme"
  }
}

# Subnets
resource "aws_subnet" "staging" {
  vpc_id                  = aws_vpc.staging.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "staging-subnet"
    Env     = "staging"
    Company = "acme"
  }
}

resource "aws_subnet" "dev" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "dev-subnet"
    Env     = "dev"
    Company = "acme"
  }
}

resource "aws_subnet" "prod" {
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "prod-subnet"
    Env     = "prod"
    Company = "acme"
  }
}

# Internet Gateways
resource "aws_internet_gateway" "staging" {
  vpc_id = aws_vpc.staging.id
  tags = {
    Name = "staging-ig"
    Env = "staging"
    Company = "acme"
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-ig"
    Env = "dev"
    Company = "acme"
  }
}

resource "aws_internet_gateway" "prod" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "prod-ig"
    Env = "prod"
    Company = "acme"
  }
}

# Route Tables and Associations
resource "aws_route_table" "staging" {
  vpc_id = aws_vpc.staging.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.staging.id
  }

  tags = {
    Name = "staging-rt"
    Env = "staging"
    Company = "acme"
  }
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }

  tags = {
    Name = "dev-rt"
    Env = "dev"
    Company = "acme"
  }
}

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod.id
  }

  tags = {
    Name = "prod-rt"
    Env = "prod"
    Company = "acme"
  }
}

# Route Table Associations
resource "aws_route_table_association" "staging" {
  subnet_id      = aws_subnet.staging.id
  route_table_id = aws_route_table.staging.id
}

resource "aws_route_table_association" "dev" {
  subnet_id      = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id
}

resource "aws_route_table_association" "prod" {
  subnet_id      = aws_subnet.prod.id
  route_table_id = aws_route_table.prod.id
}

# Security Groups
resource "aws_security_group" "staging" {
  name        = "staging-sg"
  vpc_id      = aws_vpc.staging.id
  description = "Allow SSH access"

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
    Name = "staging-sg"
    Env = "staging"
    Company = "acme"
  }
}

resource "aws_security_group" "dev" {
  name        = "dev-sg"
  vpc_id      = aws_vpc.dev.id
  description = "Allow SSH access"

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
    Name = "dev-sg"
    Env = "dev"
    Company = "acme"
  }
}

resource "aws_security_group" "prod" {
  name        = "prod-sg"
  vpc_id      = aws_vpc.prod.id
  description = "Allow SSH access"

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
    Name = "prod-sg"
    Env = "prod"
    Company = "acme"
  }
}

###############################
# 4. EC2 Instances
###############################

variable "ami" {
  default = "ami-0e95a5e2743ec9ec9"
}

resource "aws_instance" "ec2" {
  for_each = local.ec2_instances

  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = local.subnet_map[each.value.env]
  vpc_security_group_ids = [local.sg_map[each.value.env]]
  key_name               = aws_key_pair.shared_key.key_name

  tags = {
    Name       = each.key
    app        = each.value.app
    env        = each.value.env
    role       = each.value.role
    compliance = each.value.compliance
    company    = "acme"
  }
}
