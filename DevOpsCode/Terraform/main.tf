provider "aws"{

  region     = var.region
}


resource "aws_eip" "web"{

  instance = aws_instance.web.id     # Create elastic IP in aws and attach it on instance web
  tags     = merge(var.common_tag, {Name = "Server IP web-${var.common_tag["Environment"]}"})
}

resource "aws_eip" "db"{

  instance = aws_instance.db.id     # Create elastic IP in aws and attach it on instance db
  tags     = merge(var.common_tag, {Name = "Server IP db-${var.common_tag["Environment"]}"})
}



resource "aws_instance" "web" {
    ami                    = data.aws_ami.latest_ubuntu.id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.web.id]
    tags                   = merge(var.common_tag, {Name = "Web-${var.common_tag["Environment"]}-${var.current_version}"})
    availability_zone      = data.aws_availability_zones.availability.names[0]
    key_name               = aws_key_pair.generated_key_web.key_name
    
  lifecycle {
   create_before_destroy = true # the server will be destroyed after create new server
  }

  depends_on = [
    aws_instance.db
  ]
}

resource "aws_instance" "db" {
    ami                    = data.aws_ami.latest_aws_linux.id
    instance_type          = var.instance_type
    vpc_security_group_ids = [aws_security_group.db.id]
    tags                   = merge(var.common_tag, {Name = "DB-${var.common_tag["Environment"]}-${var.current_version}"})
    availability_zone      = data.aws_availability_zones.availability.names[1] 
    key_name               = aws_key_pair.generated_key_db.key_name
  
  
  lifecycle {
  #prevent_destroy = true # the server will not be destroyed 
  }
}



resource "aws_security_group" "db" {
  name        = "${var.current_version} security group DB"
  description = "SecurityGroup for db Dev "
  
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
  name        = "${var.current_version} security group Web"
  description = "SecurityGroup for web Dev "
  
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