resource "aws_lb" "po_lin_multistack" {
  name               = "po-lin-main-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.po_lin_public_subnet.id, aws_subnet.po_lin_private_subnet_redis.id]
#  security_groups    = [module.lb_security_group.this_security_group_id]
}

resource "aws_lb_listener" "po_lin_multistack" {
  load_balancer_arn = aws_lb.po_lin_multistack.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.po_lin_multistack.arn
  }
}

resource "aws_lb_target_group" "po_lin_multistack" {
  name     = "po-lin-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.po_lin_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

resource "aws_instance" "po_lin_server_1" {
  ami           = "ami-0025245f3ca0bcc82"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.po_lin_public_subnet.id
  tags = {
    Name = "po_lin_frontend"
  }
}

resource "aws_instance" "server_2" {
  ami           = "ami-0025245f3ca0bcc82"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.po_lin_private_subnet_redis.id
  tags = {
    Name = "po_lin_backend"
  }
}

resource "aws_instance" "server_3" {
  ami           = "ami-0025245f3ca0bcc82"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.po_lin_private_subnet_postgresql.id
  tags = {
    Name = "po_lin_database"
  }
}



# variable "server_names" {
#   type    = set(string)
#   default = ["po_lin_frontend", "po_lin_backend", "po_lin_database"]
# }
 
# resource "aws_instance" "servers" {
#   for_each      = var.server_names
#   ami           = "ami-0025245f3ca0bcc82"
#   instance_type = "t3.micro"
#   subnet_id              = 
#   tags = {
#     Name = each.key
#   }
# }

provider "aws" {
  alias  = "dublin"
  region = "eu-west-1"
}

resource "aws_vpc" "po_lin_vpc" {
 cidr_block           = "20.0.0.0/16"
 enable_dns_support   = true
 enable_dns_hostnames = true

 tags = {
   Name = "Po-Lin-VPC"
 }
}

resource "aws_subnet" "po_lin_public_subnet" {
  vpc_id                  = aws_vpc.po_lin_vpc.id
  cidr_block              = "20.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
 
  tags = {
    Name = "Po-Lin-PublicSubnet"
  }
}

resource "aws_subnet" "po_lin_private_subnet_redis" {
  # vpc_id                  = aws_vpc.po_lin_vpc.id
  vpc_id                  = aws_vpc.po_lin_vpc.id
  cidr_block              = "20.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
 
  tags = {
    Name = "PrivateSubnetRedis"
  }
}

resource "aws_internet_gateway" "po_lin_igw" {
  vpc_id = aws_vpc.po_lin_vpc.id
 
  tags = {
    Name = "Po-Lin-InternetGateway"
  }
}

resource "aws_route_table" "po_lin_public_rt" {
  vpc_id = aws_vpc.po_lin_vpc.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.po_lin_igw.id
  }
 
  tags = {
    Name = "Po-Lin-PublicRouteTable"
  }
}

resource "aws_route_table" "po_lin_private_rt_redis" {
  vpc_id = aws_vpc.po_lin_vpc.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.po_lin_igw.id
  }
 
  tags = {
    Name = "Po-Lin-PrivateRouteTable_Redis"
  }
}

resource "aws_route_table" "po_lin_private_rt_postgresql" {
  vpc_id = aws_vpc.po_lin_vpc.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.po_lin_igw.id
  }
 
  tags = {
    Name = "Po-Lin-PrivateRouteTable_PostgreSQL"
  }
}

resource "aws_subnet" "po_lin_private_subnet_postgresql" {
  vpc_id                  = aws_vpc.po_lin_vpc.id
  cidr_block              = "20.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
 
  tags = {
    Name = "Po-Lin-PrivateSubnetPostgreSQL"
  }
}

resource "aws_route_table_association" "po_lin_public_rt_assoc" {
  subnet_id      = aws_subnet.po_lin_public_subnet.id
  route_table_id = aws_route_table.po_lin_public_rt.id
}

resource "aws_route_table_association" "po_lin_private_rt_assoc_redis" {
  subnet_id      = aws_subnet.po_lin_private_subnet_redis.id
  route_table_id = aws_route_table.po_lin_private_rt_redis.id
}

resource "aws_route_table_association" "po_lin_private_rt_assoc_postgresql" {
  subnet_id      = aws_subnet.po_lin_private_subnet_postgresql.id
  route_table_id = aws_route_table.po_lin_private_rt_postgresql.id
}