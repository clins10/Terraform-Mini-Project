# create aws provider
provider "aws" {
  region = var.region
}

# create aws vpc
resource "aws_vpc" "mini-proj_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "mini-proj_vpc"
  }
}

# create Internet Gateway
resource "aws_internet_gateway" "mini-proj_internet_gateway" {
  vpc_id = aws_vpc.mini-proj_vpc.id
  tags = {
    Name = "mini-proj_internet_gateway"
  }
}

# create aws public Route Table
resource "aws_route_table" "mini-proj_public_route_table" {
  vpc_id = aws_vpc.mini-proj_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mini-proj_internet_gateway.id
  }
  tags = {
    Name = "mini-proj_public_route_table_public"
  }
}

# create aws public subnet dynamically
# resource "aws_subnet" "public_subnets" {
#   for_each = var.subnets
#   vpc_id                  = aws_vpc.mini-proj_vpc.id
#   cidr_block              = each.value["cidr"]
#   map_public_ip_on_launch = true
#   availability_zone_id       = each.value["az"]
#   tags = {
#     Name = "${each.key}"
#   }
# }

# create public subnet 1
resource "aws_subnet" "mini-proj_public_subnet1" {
  vpc_id                  = aws_vpc.mini-proj_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "mini-proj_public_subnet1"
  }
}

# create public subnet 2
resource "aws_subnet" "mini-proj_public_subnet2" {
  vpc_id                  = aws_vpc.mini-proj_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "mini-proj_public_subnet2"
  }
}

# associate public subnets with public route table using count function
resource "aws_route_table_association" "mini-proj_public_subnets_association" {
  subnet_id      = aws_subnet.mini-proj_public_subnet1.id
  route_table_id = aws_route_table.mini-proj_public_route_table.id
}

# associate public subnet 2 with public route table
resource "aws_route_table_association" "mini-proj_public_subnet2_association" {
  subnet_id      = aws_subnet.mini-proj_public_subnet2.id
  route_table_id = aws_route_table.mini-proj_public_route_table.id
}


# create aws acl # acl
# acl = access control list
resource "aws_network_acl" "mini-proj_acl" {
  vpc_id     = aws_vpc.mini-proj_vpc.id
  subnet_ids = [aws_subnet.mini-proj_public_subnet1.id, aws_subnet.mini-proj_public_subnet2.id]
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "mini-proj_acl"
  }
}

# create aws security group for ALB
# ceate Security Group for the ec2


# create 3 aws ec2 instances
resource "aws_instance" "terraproject_ec2_1" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  # key_name               = "terra-project_key"
  key_name               = "terra-key"
  subnet_id              = aws_subnet.mini-proj_public_subnet1.id
  vpc_security_group_ids = [aws_security_group.mini-proj_ec2_sg_rule.id]
  security_groups        = [aws_security_group.mini-proj_ec2_sg_rule.id]
  availability_zone     = "us-east-1a"
  tags = { 
    Name = "terraproject_ec2_1"
    source = "terraform"
  }
}

# the 2nd ec2
resource "aws_instance" "terraproject_ec2_2" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  # key_name               = "terra-project_key"
  key_name               = "terra-key"
  subnet_id              = aws_subnet.mini-proj_public_subnet2.id
  vpc_security_group_ids = [aws_security_group.mini-proj_ec2_sg_rule.id]
  security_groups        = [aws_security_group.mini-proj_ec2_sg_rule.id]
  availability_zone     = "us-east-1b"
  tags = { 
    Name = "terraproject_ec2_2"
    source = "terraform"
  }
}

# the 3rd ec2
resource "aws_instance" "terraproject_ec2_3" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  # key_name               = "terra-project_key"
  key_name               = "terra-key"
  subnet_id              = aws_subnet.mini-proj_public_subnet1.id
  vpc_security_group_ids = [aws_security_group.mini-proj_ec2_sg_rule.id]
  security_groups        = [aws_security_group.mini-proj_ec2_sg_rule.id]
  availability_zone     = "us-east-1a"
  tags = { 
    Name = "terraproject_ec2_3"
    source = "terraform"
  }
}

# create a local file to store the IPaddresses of ec2 instances
resource "local_file" "ipaddresses" {
  filename = "/ansible/host-inventory"
  content  = <<EOT
    ${aws_instance.terraproject_ec2_1.public_ip}
    ${aws_instance.terraproject_ec2_2.public_ip}
    ${aws_instance.terraproject_ec2_3.public_ip}
  EOT
}

# resource "local_file" "IPaddresses" {
#   filename = "~/mini-project/host-inventory"
#   content  =  join(",", aws_instance.mini-proj_ec2.*.public_ip)
# }

# create aws Application load balancer
resource "aws_lb" "mini-proj_alb" {
  name               = "mini-proj-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mini-proj_load-balancer_sg.id]
  subnets            = [aws_subnet.mini-proj_public_subnet1.id, aws_subnet.mini-proj_public_subnet2.id]
  # enable_cross_zone_load_balancing = false
  enable_deletion_protection = false
  depends_on = [
    aws_instance.terraproject_ec2_1,
    aws_instance.terraproject_ec2_2,
    aws_instance.terraproject_ec2_3   
  ]
  tags = {
    Name = "mini-proj-alb"
  }
}

# create aws target group
resource "aws_lb_target_group" "mini-proj_target_group" {
  name        = "mini-proj-target-group"
  port        = var.outbound_port
  protocol    = var.protocol
  vpc_id      = aws_vpc.mini-proj_vpc.id
  target_type = "instance"
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 3
    interval            = 10
    protocol            = var.protocol
    matcher             = "200"
    path                = "/"
  }

  tags = {
    Name = "mini-proj-target-group"
  }
}

# create aws listener
resource "aws_lb_listener" "mini-proj_listener" {
  load_balancer_arn = aws_lb.mini-proj_alb.arn
  port              = var.outbound_port
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mini-proj_target_group.arn
  }
}

# create aws listener rule
resource "aws_lb_listener_rule" "mini-proj_alb_listener_rule" {
  listener_arn = aws_lb_listener.mini-proj_listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mini-proj_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# attach the target group to the load balancer using count function
resource "aws_lb_target_group_attachment" "mini-proj_alb_target_group_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.mini-proj_target_group.arn
  target_id        = element([aws_instance.terraproject_ec2_1.id, aws_instance.terraproject_ec2_2.id, aws_instance.terraproject_ec2_3.id], count.index)
  port             = var.outbound_port
}

# create a local-exec provisioner to run ansible playbook
provisioner "local-exec" {
  command = "ansible-playbook -i host-inventory playbook.yml"
}




























































































































