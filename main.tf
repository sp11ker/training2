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
# 2. Security Groups (Allow SSH) - separate for dev and prod
###############################

resource "aws_security_group" "dev_ssh" {
  name        = "dev-sg"
  description = "Allow SSH for dev"
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
    Name = "dev-sg"
  }
}

resource "aws_security_group" "prod_ssh" {
  name        = "prod-sg"
  description = "Allow SSH for prod"
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
    Name = "prod-sg"
  }
}

###############################
# 3. VPC: dev-vpc
###############################
resource "aws_vpc" "dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "dev-vpc"
    Env = "dev"
  }
}

resource "aws_subnet" "dev" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev-subnet"
  }
}

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "dev-igw"
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
  }
}

resource "aws_route_table_association" "dev" {
  subnet_id      = aws_subnet.dev.id
  route_table_id = aws_route_table.dev.id
}

resource "aws_instance" "web-dev" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.dev.id
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.dev_ssh.id]

  tags = {
    Name = "web"
    Role = "web"
    App = "pos"
    Env = "dev"
  }
}

resource "aws_instance" "proc-dev" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.dev.id
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.dev_ssh.id]

  tags = {
    Name = "proc"
    Role = "proc"
    App = "pos"
    Env = "dev"
  }
}

resource "aws_instance" "db-dev" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.dev.id
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.dev_ssh.id]

  tags = {
    Name = "db"
    Role = "db"
    App = "pos"
    Env = "dev"
  }
}

###############################
# 4. VPC: prod-vpc
###############################
resource "aws_vpc" "prod" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "prod-vpc"
    Env = "prod"
  }
}

resource "aws_subnet" "prod" {
  vpc_id                  = aws_vpc.prod.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_internet_gateway" "prod" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "prod-igw"
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
  }
}

resource "aws_route_table_association" "prod" {
  subnet_id      = aws_subnet.prod.id
  route_table_id = aws_route_table.prod.id
}

resource "aws_instance" "web-prod" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.prod.id                      
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.prod_ssh.id] 
  tags = {
    Name = "web"
    Role = "web"
    App = "finance"
    Env = "prod"
  }
}

resource "aws_instance" "proc-prod" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.prod.id 
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.prod_ssh.id] 
  tags = {
    Name = "proc"
    Role = "proc"
    App = "finance"
    Env = "prod"
  }
}

resource "aws_instance" "db-prod" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.prod.id 
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.prod_ssh.id]  
  tags = {
    Name = "db"
    Role = "db"
    App = "finance"
    Env = "prod"
  }
}

###############################
# 5. Null resource to confirm key
###############################
resource "null_resource" "post_setup" {
  provisioner "local-exec" {
    command = "echo 'Private key saved at my-keypair.pem with 600 permissions'"
  }

  depends_on = [
    local_file.private_key_pem
  ]
}
