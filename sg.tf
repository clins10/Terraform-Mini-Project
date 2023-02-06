# create security group for ALB
resource "aws_security_group" "mini-proj_load-balancer_sg" {
  name        = "mini-proj_load-balancer_sg"
  description = "security group for the load balancer"
  vpc_id      = aws_vpc.mini-proj_vpc.id

  # inbound rule
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rule
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# create aws ec2 security group
resource "aws_security_group" "mini-proj_ec2_sg_rule" {
  name        = "mini-proj_ec2_sg_to_allow_ssh-http-https"
  description = "security group for the ec2 that allows SSH, HTTP and HTTPS ingress for a private instance"
  vpc_id      = aws_vpc.mini-proj_vpc.id

  # inbound rule
  ingress {
    description     = "http"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.mini-proj_load-balancer_sg.id]
  }

  ingress {
    description     = "https"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.mini-proj_load-balancer_sg.id]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rule
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "mini-proj_ec2_sg_rule"
  }
}
