resource "aws_lb" "mv_lb" {
  name               = "sharmi-lb-asg"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mv_sg_for_elb.id]
  subnets            = values(aws_subnet.pub_subnets)[*].id
  depends_on         = [aws_internet_gateway.igw]
}


resource "aws_lb_target_group" "mv_alb_tg" {
  name     = "sh-tf-lb-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

resource "aws_lb_listener" "mv_front_end" {
  load_balancer_arn = aws_lb.mv_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mv_alb_tg.arn
  }
}


# Generate SSH key pair
resource "tls_private_key" "my_keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "nginx-lb-vm-keypair"
  public_key = tls_private_key.my_keypair.public_key_openssh
}

# ASG with Launch template
resource "aws_launch_template" "mv_ec2_launch_templ" {
  name_prefix   = "lb_nginx_vms"
  image_id      = "ami-07a6e3b1c102cdba8" #specific for each region
  instance_type = "t2.micro"
  user_data     = filebase64("user_data.sh")
  key_name =  aws_key_pair.my_keypair.key_name

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.pvt_subnets[0].id
    security_groups             = [aws_security_group.mv_sg_for_ec2.id]
  }
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "LB Nginx Instances"
    }
  }
}

resource "aws_autoscaling_group" "mv_asg" {
  # no of instances
  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  # source
  target_group_arns = [aws_lb_target_group.mv_alb_tg.arn]

  vpc_zone_identifier = [ # use private subnet
    aws_subnet.pvt_subnets[0].id
  ]

  launch_template {
    id      = aws_launch_template.mv_ec2_launch_templ.id
    version = "$Latest"
  }
}
