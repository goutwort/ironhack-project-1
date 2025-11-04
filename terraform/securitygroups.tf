resource "aws_security_group" "tiffany_public_SG" {
  name        = "tiffany_public_SG"
  description = "Allow HTTP and HTTPS traffic from the internet"

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
    from_port = 0
    to_port = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 #   security_groups = [
 #     aws_security_group.tiffany_private_SG_redis.id,
 #     aws_security_group.tiffany_private_SG_postgresql.id
 #   ]
  }
  vpc_id = aws_vpc.tiffany_vpc.id
}

resource "aws_security_group" "tiffany_private_SG_redis" {
  name        = "tiffany_private_SG_redis"
  description = "Allow inbound traffic from SG1 instances to port 6379 and outbound to SG3"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.tiffany_public_SG.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.tiffany_vpc.id
}

resource "aws_security_group" "tiffany_private_SG_postgresql" {
  name        = "tiffany_private_SG_postgresql"
  description = "Allow inbound traffic on port 5432 from SG2 and SG1 instances"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [
#      aws_security_group.tiffany_private_SG_redis.id,
      aws_security_group.tiffany_public_SG.id
    ]
  }

  # TODO - Change to only allow 22 access from worker and frontend
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
#    security_groups = [aws_security_group.tiffany_public_SG.id]    
  }
  vpc_id = aws_vpc.tiffany_vpc.id
}