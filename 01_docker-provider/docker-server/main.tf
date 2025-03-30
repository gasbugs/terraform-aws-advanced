module "vpc" {
  source               = "terraform-aws-modules/vpc/aws" # 
  version              = "5.13.0"
  name                 = "terraform-demo-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = false
  enable_dns_hostnames = true
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.1"

  name = "al2023-ec2"

  instance_type               = "t3.micro"
  associate_public_ip_address = true

  ami = data.aws_ami.al2023.id

  key_name = aws_key_pair.my_key_pair.key_name # EC2에 연결할 SSH 키 이름

  vpc_security_group_ids = [aws_security_group.ec2_sg.id] # 보안 그룹 연결
  subnet_id              = module.vpc.public_subnets[0]   # 서브넷 ID

  # EC2 인스턴스 부팅 시 실행할 스크립트
  user_data = <<-EOF
              #!/bin/bash
              dnf update && dnf install docker -y
              EOF
}

# 최신 Amazon Linux 2023 AMI 검색
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# 랜덤 인트 생성 (1000 ~ 9999 범위)
resource "random_integer" "key_suffix" {
  min = 1000
  max = 9999
}

# HTTP 및 SSH 트래픽을 허용하는 보안 그룹 정의
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2_sg" # 보안 그룹 이름 접두사

  ingress {
    from_port   = 22            # 허용할 SSH 포트 (22)
    to_port     = 22            # 허용할 SSH 포트 (22)
    protocol    = "tcp"         # 프로토콜 (TCP)
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 SSH 트래픽 허용
  }

  ingress {
    from_port   = 80            # 허용할 HTTP 포트 (80)
    to_port     = 80            # 허용할 HTTP 포트 (80)
    protocol    = "tcp"         # 프로토콜 (TCP)
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 HTTP 트래픽 허용
  }

  egress {
    from_port   = 0             # 아웃바운드 포트 범위 시작
    to_port     = 0             # 아웃바운드 포트 범위 끝
    protocol    = "-1"          # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP로의 아웃바운드 트래픽 허용
  }

  vpc_id = module.vpc.vpc_id # 연결할 VPC ID
  tags = {
    Name = "ec2-sg" # 보안 그룹에 이름 태그 추가
  }
}

# 로컬 경로의 public key 읽기
resource "aws_key_pair" "my_key_pair" {
  key_name   = "my-key-${random_integer.key_suffix.result}" # 랜덤 인트 포함한 키 이름
  public_key = file(var.key_path)                           # 지정된 경로에서 public key 읽기
}

output "ec2_domain" {
  value = module.ec2_instance.public_dns
}
