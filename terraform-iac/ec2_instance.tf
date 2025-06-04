
# ec2_instance.tf
# Configure AWS provider
provider "aws" {
  region = "us-east-1"
}

# Generate SSH key pair
resource "tls_private_key" "deployer_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file
resource "local_file" "private_key" {
  content              = tls_private_key.deployer_key.private_key_pem
  filename             = "${path.module}/key-pair.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

# Save public key to local file
resource "local_file" "public_key" {
  content              = tls_private_key.deployer_key.public_key_openssh
  filename             = "${path.module}/key-pair.pem.pub"
  file_permission      = "0644"
  directory_permission = "0700"
}

# Create AWS key pair using generated public key
resource "aws_key_pair" "deployer" {
  key_name   = "key-pair"
  public_key = tls_private_key.deployer_key.public_key_openssh
}

# Define the Security Group
resource "aws_security_group" "devsecops_sg" {
  name        = "devsecops-security-group"
  description = "Security group for DevSecOps environment"
 

  # SSH access from specific IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["191.111.242.104/32"]
    description = "SSH Access"
  }
  # Allow port 5173 TCP from anywhere (0.0.0.0/0)
  ingress {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Frontend Vite Dev Server Access"
  }

  # HTTP (Web) access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Web Access"
  }

  # HTTPS (Secure Web) access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Secure Access"
  }

  # SMTP
  ingress {
    from_port   = 25
    to_port     = 25
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SMTP Port 25"
  }

  # SMTPS (Port 465)
  ingress {
    from_port   = 465
    to_port     = 465
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SMTPS Port 465"
  }

  # SMTP Submission (Port 587)
  ingress {
    from_port   = 587
    to_port     = 587
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SMTP Submission Port 587"
  }

  # Jenkins (8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Jenkins CI/CD"
  }

  # SonarQube (9000)
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SonarQube"
  }

  # Grafana (3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Grafana Dashboard"
  }

  # Prometheus (9090)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Prometheus Monitoring"
  }

  # OWASP ZAP (8090)
  ingress {
    from_port   = 8090
    to_port     = 8090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "OWASP ZAP DAST"
  }

  # Trivy (4954)
  ingress {
    from_port   = 4954
    to_port     = 4954
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Trivy API"
  }

  # Dev Server (7000)
  ingress {
    from_port   = 7000
    to_port     = 7000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Local Dev Server"
  }

  # Docker Registry (5000)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Docker Registry"
  }


  # Egress rule (Allow all outbound)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devsecops-sg"
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.xlarge"
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.devsecops_sg.id]



  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name = "Wasai-DevSecOps"
  }
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "instance_name" {
  value = aws_instance.web.tags["Name"]
}
