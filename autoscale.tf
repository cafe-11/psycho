resource "aws_launch_configuration" "terraform-lc" {
  name_prefix     = "terraform-lc"
  image_id        =  "ami-08c2c46de137e8d30"
  instance_type   = "t2.micro"
  key_name        = "temp"
  security_groups = [aws_security_group.asg_sg.id]
   root_block_device {
    volume_size = var.vol_size
  }


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "terraform-asg" {
  name                      = "terraform-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 10
  health_check_type         = "EC2"   #by default ec2....but you can choose anyone
  desired_capacity          = 1
  force_delete              = true
  launch_configuration      = aws_launch_configuration.terraform-lc.name
  vpc_zone_identifier       = [aws_subnet.public_test_subnet[0].id, aws_subnet.public_test_subnet[1].id]
}

resource "aws_autoscaling_policy" "scale-up" {
  name                   = "scale-up"
  autoscaling_group_name = aws_autoscaling_group.terraform-asg.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "targetgroup/test-tg/04f74f15a0df0a36"
    }

    target_value = 1

  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.terraform-asg.id
  lb_target_group_arn    = aws_lb_target_group.test-tg.arn
}


