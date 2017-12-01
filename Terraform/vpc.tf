# create a VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = "10.16.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "Demo VPC"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.vpc_main.id}"
}

resource "aws_route" "internet_access" {
  route_table_id          = "${aws_vpc.vpc_main.main_route_table_id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.default.id}"
}

# Create a public subnet in us-east-1a
resource "aws_subnet" "demo_sn_1" {
  vpc_id                  = "${aws_vpc.vpc_main.id}"
  cidr_block              = "10.16.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.tags}"
  }
}
# Create a public subnet in us-east-1b
resource "aws_subnet" "demo_sn_2" {
  vpc_id                  = "${aws_vpc.vpc_main.id}"
  cidr_block              = "10.16.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.tags}"
  }
}
# Create a public subnet in us-east-1c
resource "aws_subnet" "demo_sn_3" {
  vpc_id                  = "${aws_vpc.vpc_main.id}"
  cidr_block              = "10.16.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.tags}"
  }
}
# Create a SecurityGroup for ELB
resource "aws_security_group" "elb" {
  name        = "demo_sg_elb"
  description = "Security group for ELBs"
  vpc_id      = "${aws_vpc.vpc_main.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound internet access
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}
# Create security group for  instance
resource "aws_security_group" "default" {
  name        = "demo_sg_instance"
  description = "Security group for instances"
  vpc_id      = "${aws_vpc.vpc_main.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.16.0.0/16"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.16.0.0/16"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Create an ELB in us-east-1
resource "aws_elb" "demo_elb" {
  name = "ELB"
  security_groups    = ["${aws_security_group.elb.id}"]
  #availability_zones = ["${split(",", var.availability_zones)}"]
  subnets            = ["${aws_subnet.demo_sn_1.id}","${aws_subnet.demo_sn_2.id}","${aws_subnet.demo_sn_3.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "tcp"
    lb_port           = 8080
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
}
# Create the Autoscaling group in 3 subnets in us-east-1
resource "aws_autoscaling_group" "demo_asg" {
  vpc_zone_identifier  = ["${aws_subnet.demo_sn_1.id}","${aws_subnet.demo_sn_2.id}","${aws_subnet.demo_sn_3.id}"]
  name                 = "Demo Auto Scaling Group"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.web.name}"
  load_balancers       = ["${aws_elb.demo_elb.name}"]
  tag {
    key                 = "Name"
    value               = "demo-asg"
    propagate_at_launch = "true"
  }
}
#Create the launch configuration for ASG
resource "aws_launch_configuration" "web" {
  name          = "demo hosts"
  image_id      = "${lookup(var.aws_amis, var.region)}"
  instance_type = "${var.instance_type}"

  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  #user_data       = "${file("userdata.sh")}"
  key_name        = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}
