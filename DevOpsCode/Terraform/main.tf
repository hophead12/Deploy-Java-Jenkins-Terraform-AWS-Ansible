provider "aws"{ 
  region     = var.region
}

#===============BACKEND============================

terraform {
  backend "s3" {
    bucket = "petclinic-tf-state"
    key    = "dev/terraform.tfstate"
    region = "eu-central-1"
  }
}
  


#==================ALC===ASG===ELB=================

resource "aws_launch_configuration" "web" {
  name_prefix         = "Web-${var.current_environment}-V${var.current_version}"
  image_id            = data.aws_ami.latest_ubuntu.id
  instance_type       = var.instance_type
  security_groups     = [aws_security_group.web.id]
  key_name            = aws_key_pair.generated_key_web.key_name
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_db_instance.db
  ]
}


resource "aws_autoscaling_group" "web" {
  name = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 3
  min_elb_capacity     = 2
  health_check_type    = "ELB"

  vpc_zone_identifier  = [aws_subnet.main.id, aws_subnet.main2.id, aws_subnet.main3.id] #!!!
  load_balancers       = [aws_elb.web.name] 

  dynamic "tag" {
    for_each = {
        Name = "Web-${var.current_environment}-V${var.current_version}"
        Owner = "Danylo Bosenko"
        Project = "Final-Task"
    }
  content {
        key     = tag.key
        value   = tag.value
        propagate_at_launch = true
   }  
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_db_instance.db
  ] 
}


resource "aws_elb" "web" {
    name = "WebServer-${var.current_environment}-V${var.current_version}"
    security_groups = [aws_security_group.web.id]
    subnets = [aws_subnet.main.id, aws_subnet.main2.id, aws_subnet.main3.id]
    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }
    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      target              = "TCP:22"
      interval            = 15
    }
    tags = merge(var.common_tag, {Name = "WebServer-Highly-Avaibility-ELB"})

    depends_on = [
      aws_db_instance.db
    ]
}

#=====================DB=========================



resource "aws_db_instance" "db" {
  allocated_storage       = 10
  
  db_subnet_group_name    = aws_db_subnet_group.main.name
  
  identifier              = "db-petclinic" 
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  #publicly_accessible     = true

  db_name                 = "petclinic"
  username                = var.usernamedb 
  password                = var.passworddb

  vpc_security_group_ids  = [aws_security_group.db.id]
  availability_zone       = data.aws_availability_zones.availability.names[1]
  #lifecycle {  
   # prevent_destroy = true 
  #}
}                    

#===================SECURITY GROUP==========================

resource "aws_security_group" "db" {
  name        = "Security group DB-${var.current_environment}-V${var.current_version}"
  description = "SecurityGroup for db"
  vpc_id      = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.allow_ports_db
    content {
          from_port        = ingress.value
          to_port          = ingress.value
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow 3306,ssh"
  }
}


resource "aws_security_group" "web" {
  name        = "Security group Web-${var.current_environment}-V${var.current_version}"
  description = "SecurityGroup for web"
  vpc_id      = aws_vpc.main.id
  dynamic "ingress" {
    for_each = var.allow_ports
    content {
          from_port        = ingress.value
          to_port          = ingress.value
          protocol         = "tcp"
          cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow http/https/ssh"
  }
}