# Create main VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { 
    Name = "NachoCaniculoP3VPC"
  }
}

# Attach an Internet Gateway to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { 
    Name = "NachoCaniculoP3IGW" 
  }
}

# Public subnet for resources accessible from the internet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
  tags = { 
    Name = "NachoCaniculoP3PublicNet"
  }
}

# Private subnet for internal resources
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-1c"
  tags = { 
    Name = "NachoCaniculoP3PrivateNet" 
  }
}

# Public route table with default route to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { 
    Name = "NachoCaniculoP3PublicRT" 
  }
}

# Associate public subnet with the public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group for web servers allowing HTTP, HTTPS, SSH
resource "aws_security_group" "web_sg" {
  name        = "NachoCaniculoP3EC2SEG"
  description = "Allow HTTP, HTTPS, and SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# Security group for database allowing MySQL access from web servers
resource "aws_security_group" "db_sg" {
  name        = "NachoCaniculoP3DBSG"
  description = "Allow MySQL and SSH access"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

# Generate RSA key pair using Terraform
resource "tls_private_key" "nachocaniculo_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS
resource "aws_key_pair" "nachocaniculo_keypair" {
  key_name   = "NachoCaniculo-kepair"
  public_key = tls_private_key.nachocaniculo_keypair.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_pem" {
  content  = tls_private_key.nachocaniculo_keypair.private_key_pem
  filename = "${path.module}/../Ansible/NachoCaniculo.pem"
}

# Launch web server instance in the public subnet
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = aws_key_pair.nachocaniculo_keypair.key_name

  tags = {
    Name = "NachoCaniculoP3WebEC2"
    role = "web"
  }
}

# Launch database instance
resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = aws_key_pair.nachocaniculo_keypair.key_name

  tags = {
    Name = "NachoCaniculoP3DBEC2"
    role = "db"
  }
}