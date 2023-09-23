resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "sub-1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "sub-2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

}
resource "aws_route_table" "myrp" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0" //everything inside the vpc should connect to this
    gateway_id = aws_internet_gateway.igw.id

  }

}
resource "aws_route_table_association" "rta-1" {
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.myrp.id
}
resource "aws_route_table_association" "rta-2" {
  subnet_id      = aws_subnet.sub-2.id
  route_table_id = aws_route_table.myrp.id
}

resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0 //all ports allowed
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "web-sg"
  }
}
resource "aws_s3_bucket" "example" {
  bucket = "kavya-tf-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_instance" "webserver-1" {
  ami                    = "ami-08e5424edfe926b43"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id              = aws_subnet.sub-1.id
  user_data              = base64encode(file("userdata.sh"))

}
resource "aws_instance" "webserver-2" {
  ami                    = "ami-08e5424edfe926b43"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  subnet_id              = aws_subnet.sub-2.id
  user_data              = base64encode(file("userdata1.sh"))

}
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web-sg.id]
  subnets            = [aws_subnet.sub-1.id, aws_subnet.sub-2.id]
}
resource "aws_lb_target_group" "my-tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}
resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.my-tg.arn
  target_id        = aws_instance.webserver-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.my-tg.arn
  target_id        = aws_instance.webserver-2.id
  port             = 80
}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my-tg.arn
    type             = "forward"
  }

}
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}