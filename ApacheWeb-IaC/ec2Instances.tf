resource "aws_instance" "ApacheApp-BastionHost" {
  ami = var.amznlnx2
  instance_type = var.instype
  availability_zone = var.AvailZone-1
  key_name = var.mykey
  subnet_id = aws_subnet.ApacheAppVPC-PublicSubnet1.id
  vpc_security_group_ids = [ aws_security_group.ApacheAppVPC-BastionHost-SecGrp.id ]

  tags = {
    Name = "ApacheApp-BastionHost"
  }
}

resource "aws_launch_template" "ApacheApp-LaunchTemplate" {
  image_id = var.amznlnx2
  instance_type = var.instype
  key_name = var.mykey
  user_data = file("user-data.sh")
  vpc_security_group_ids = [ aws_security_group.ApacheAppVPC-LoadBalancer-SecGrp.id ]
  
  tags = {
    Name = "ApacheApp-LaunchTemplate"
  }
}

resource "aws_lb" "ApacheApp-LoadBalancer" {
    name = "ApacheApp-LoadBalancer"
    internal = false
    load_balancer_type = "application"
    security_groups = [ aws_security_group.ApacheAppVPC-LoadBalancer-SecGrp.id ]
    subnets = [ aws_subnet.ApacheAppVPC-PrivateSubnet1.id , aws_subnet.ApacheAppVPC-PrivateSubnet2.id ]

    tags = {
      Name = "ApacheApp-LoadBalancer"
    }
}

resource "aws_lb_listener" "ApacheApp-LoadBalancerListenerHttp" {
    load_balancer_arn = aws_lb.ApacheApp-LoadBalancer.arn
    protocol = "HTTP"
    port = 80
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ApacheApp-TargetGroupHttp.arn
   }

   tags = {
     Name = "ApacheApp-LoadBalancerListenerHttp"
   }
}

resource "aws_lb_listener" "ApacheApp-LoadBalancerListenerHttps" {
    load_balancer_arn = aws_lb.ApacheApp-LoadBalancer.arn
    protocol = "HTTPS"
    port = 443
    certificate_arn = var.LoadBalancerCert
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ApacheApp-TargetGroupHttps.arn
  }

  tags = {
    Name = "ApacheApp-LoadBalancerListenerHttps"
  }
}

resource "aws_lb_target_group" "ApacheApp-TargetGroupHttp" {
  name        = "ApacheApp-TargetGroupHttp"
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.ApacheApp-vpc.id

  health_check {
    port = 443
    protocol = "HTTPS"
    timeout = 5
    interval = 10
  }

  tags = {
    Name = "ApacheApp-TargetGroupHttp"
  }
}

resource "aws_lb_target_group" "ApacheApp-TargetGroupHttps" {
  name        = "ApacheApp-TargetGroupHttps"
  target_type = "alb"
  port        = 443
  protocol    = "TCP"
  vpc_id      = aws_vpc.ApacheApp-vpc.id

  health_check {
    port = 443
    protocol = "HTTPS"
    timeout = 5
    interval = 10
  }

  tags = {
    Name = "ApacheApp-TargetGroupHttps"
  }
}

resource "aws_autoscaling_group" "ApacheApp-AutoScalingGroup" {
    name = "ApacheApp-AutoScalingGroup"
    max_size = 2
    min_size = 1
    desired_capacity = 1
    health_check_type = "ELB"
    health_check_grace_period = 300
    vpc_zone_identifier = [ aws_subnet.ApacheAppVPC-PrivateSubnet1.id, aws_subnet.ApacheAppVPC-PrivateSubnet2.id ]
    target_group_arns = [ aws_lb_target_group.ApacheApp-TargetGroupHttp.arn, aws_lb_target_group.ApacheApp-TargetGroupHttps.arn ]
    launch_template {
      id = aws_launch_template.ApacheApp-LaunchTemplate.id
      version = "$Latest"
    }
}

resource "aws_autoscaling_attachment" "ApacheApp-AutoScalingGroup-Attach" {
  autoscaling_group_name = aws_autoscaling_group.ApacheApp-AutoScalingGroup.id
  lb_target_group_arn = aws_lb_target_group.ApacheApp-TargetGroupHttp.arn
}