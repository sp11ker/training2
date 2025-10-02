provider "aws" {
  region = "us-east-1"
}

###############################
# 1. Key Pair (shared)
###############################
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-keypair"
  public_key = tls_private_key.example.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/my-keypair.pem"
  file_permission = "0600"
}

###############################
# 2. VPCs and Networking
###############################

# IT VPC
resource "aws_vpc" "it" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name    = "it-vpc"
    Env     = "it"
    Company = "acme financing"
  }
}

resource "aws_subnet" "it" {
  vpc_id                  = aws_vpc.it.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "it-subnet"
    Env     = "it"
    Company = "acme financing"
  }
}

resource "aws_internet_gateway" "it" {
  vpc_id = aws_vpc.it.id
  tags = {
    Name    = "it-igw"
    Env     = "it"
    Company = "acme financing"
  }
}

resource "aws_route_table" "it" {
  vpc_id = aws_vpc.it.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.it.id
  }

  tags = {
    Name    = "it-rt"
    Env     = "it"
    Company = "acme financing"
  }
}

resource "aws_route_table_association" "it" {
  subnet_id      = aws_subnet.it.id
  route_table_id = aws_route_table.it.id
}

# DEV VPC
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name    = "dev-vpc"
    Env     = "dev"
    Company = "acme financing"
  }
}

resource "aws_subnet" "dev" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "dev-subnet"
    Env     = "dev"
    Company = "acme financing"
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name    = "dev-igw"
    Env     = "dev"
    Company = "acme financing"
  }
}

resource "aws_route_table" "dev" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }

  tags = {
    Name    = "dev-rt"
    Env     = "dev"
    Company = "acme financing"
  }
}

resource "aws_route_table_association" "dev" {
  subnet_id      = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id
}

# PROD VPC
resource "aws_vpc" "prod" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name    = "prod-vpc"
    Env     = "prod"
    Company = "acme financing"
  }
}

resource "aws_subnet" "prod" {
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name    = "prod-subnet"
    Env     = "prod"
    Company = "acme financing"
  }
}

resource "aws_internet_gateway" "prod" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name    = "prod-igw"
    Env     = "prod"
    Company = "acme financing"
  }
}

resource "aws_route_table" "prod" {
  vpc_id = aws_vpc.prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod.id
  }

  tags = {
    Name    = "prod-rt"
    Env     = "prod"
    Company = "acme financing"
  }
}

resource "aws_route_table_association" "prod" {
  subnet_id      = aws_subnet.prod.id
  route_table_id = aws_route_table.prod.id
}

###############################
# 3. Security Groups (SSH Access)
###############################

resource "aws_security_group" "it_ssh" {
  name        = "it-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.it.id

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
    Name    = "it-sg"
    Env     = "it"
    Company = "acme financing"
  }
}

resource "aws_security_group" "dev_ssh" {
  name        = "dev-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.dev.id

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
    Name    = "dev-sg"
    Env     = "dev"
    Company = "acme financing"
  }
}

resource "aws_security_group" "prod_ssh" {
  name        = "prod-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.prod.id

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
    Name    = "prod-sg"
    Env     = "prod"
    Company = "acme financing"
  }
}

###############################
# 4. EC2 Instances (Dynamic Creation)
###############################

variable "instances" {
  default = {
    "it-admin"  = { env = "it",   role = "admin" }
    "it-backup" = { env = "it",   role = "backup" }
    "dev-web"   = { env = "dev",  role = "web" }
    "dev-db"    = { env = "dev",  role = "db" }
    "prod-web"  = { env = "prod", role = "web" }
    "prod-db"   = { env = "prod", role = "db" }
  }
}

resource "aws_instance" "ec2" {
  for_each = var.instances

  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = lookup({
                            it   = aws_subnet.it.id,
                            dev  = aws_subnet.dev.id,
                            prod = aws_subnet.prod.id
                          }, each.value.env)
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [lookup({
                                it   = aws_security_group.it_ssh.id,
                                dev  = aws_security_group.dev_ssh.id,
                                prod = aws_security_group.prod_ssh.id
                              }, each.value.env)]

  tags = {
    Name    = each.key
    Env     = each.value.env
    Role    = each.value.role
    Company = "acme financing"
    Project = each.value.env == "it" ? "management" : "finance"
  }
}

###############################
# 5. Output message (optional)
###############################

resource "null_resource" "post_setup" {
  provisioner "local-exec" {
    command = "echo 'Private key saved at my-keypair.pem with 600 permissions'"
  }

  depends_on = [
    local_file.private_key_pem
  ]
}
