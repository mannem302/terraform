provider "aws" { 
 region = "eu-west-3" 
} 
terraform {
  cloud {
    organization = "GSowmya"

    workspaces {
      name = "documents"
    }
  }
} 
resource "aws_key_pair" "test" { 
 key_name = "prod" 
 public_key = file("./prod.pub") 
} 
resource "aws_instance" "interns1" { 
 ami = "ami-0326f9264af7e51e2" 
 instance_type = "t2.micro"  
 availability_zone = "eu-west-3a"
 key_name = aws_key_pair.test.key_name 
 vpc_security_group_ids =["sg-0f4aa0545ddc5ba5c"]
 tags = { 
 Name = "Instance-1" 
 } 
 connection {
 type = "ssh" 
 user = "ubuntu" 
 private_key = file("./prod")  
 host = self.public_ip 
 timeout = "1m" 
 agent = false 
 } 
 provisioner "remote-exec" { 
 inline = [ 
 "sudo apt-get update", 
 "sudo apt-get install nginx -y",
 "touch index.nginx-debian.html",
 "echo '<h1> This is My Web Application 1 </h1>' | tee index.nginx-debian.html",
 "sudo mv index.nginx-debian.html /var/www/html/index.nginx-debian.html",
 "sudo systemctl restart nginx.service"
 ] 
 } 
} 
resource "aws_instance" "interns2" { 
 ami = "ami-0326f9264af7e51e2" 
 instance_type = "t2.micro"  
 availability_zone = "eu-west-3b"
 key_name = aws_key_pair.test.key_name 
 vpc_security_group_ids =["sg-0f4aa0545ddc5ba5c"]
 tags = { 
 Name = "Instance-2" 
 } 
 connection {
 type = "ssh" 
 user = "ubuntu" 
 private_key = file("./prod")  
 host = self.public_ip 
 timeout = "1m" 
 agent = false 
 } 
 provisioner "remote-exec" { 
 inline = [ 
 "sudo apt-get update", 
 "sudo apt-get install nginx -y",
 "touch index.nginx-debian.html",
 "echo '<h1> This is My Web Application </h1>' | tee index.nginx-debian.html",
 "sudo mv index.nginx-debian.html /var/www/html/index.nginx-debian.html",
 "sudo systemctl restart nginx.service"
 ] 
 } 
}
resource "aws_lb" "alb" {
  name               = "alb-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0f4aa0545ddc5ba5c"]
  subnets            = ["subnet-0963950ac84962c45", "subnet-08192616f8ac5f976"]
  tags = {
    Name = "alb-lb"
  }
}

resource "aws_lb_target_group" "alb" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-0b773dc32c1834e3b"
  health_check {
    path                = "/"
    interval            = 15
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }
  tags = {    
    Name = "alb-tg"
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_target_group_attachment" "interns1" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.interns1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "interns2" {
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.interns2.id
  port             = 80
}
