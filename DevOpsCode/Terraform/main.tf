provider "aws"{
  region     = var.region
}


#resource "aws_eip" "web"{
#
#  #instance = aws_instance.web.id     # Create elastic IP in aws and attach it on instance web
#  network_interface  = aws_network_interface.main.id
#  associate_with_private_ip = aws_network_interface.main.private_ip
#  tags     = merge(var.common_tag, {Name = "Server IP web-${var.current_environment}"})
#}



#resource "aws_instance" "web" {
#    ami                    = data.aws_ami.latest_ubuntu.id
#    instance_type          = var.instance_type
#    tags                   = merge(var.common_tag, {Name = "Web-${var.current_environment}-V${var.current_version}.${var.current_build}"})
#    availability_zone      = data.aws_availability_zones.availability.names[0]
#    key_name               = aws_key_pair.generated_key_web.key_name
#    
#  network_interface {
#    network_interface_id = aws_network_interface.main.id
#    device_index         = 0
#  }
#    
#  lifecycle {
#   create_before_destroy = true # the server will be destroyed after create new server
#  }
#
#  depends_on = [
#    aws_db_instance.db
#  ]
#}

resource "aws_launch_configuration" "web" {
  #name = "WebServer-Highly-Available-LC"
  name_prefix         = "Web-${var.current_environment}-V${var.current_version}.${var.current_build}"
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
#==========================================================================

resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  
  vpc_zone_identifier  = [aws_subnet.main.id, aws_subnet.main.id] #!!!
  load_balancers       = [aws_elb.web.name] 



  lifecycle {
    create_before_destroy = true
  }
   
}

#==================================================================

resource "aws_elb" "web" {
    availability_zones = [data.aws_availability_zones.availability.names[0], data.aws_availability_zones.availability.names[2]]
    security_groups = [aws_security_group.web.id]
    listener {
      lb_port          = 80
      lb_protocol       = "http"
      instance_port     = 80
      instance_protocol = "http"


    }
    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      target = "HTTP:80/"
      interval = 10

    }
    tags = merge(var.common_tag, {Name = "WebServer-HA-ELB"})
}



#=========================DB===========================================


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
  #  prevent_destroy = true 
  #}
}                    

#=========================SECURITY GROUP===============================

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