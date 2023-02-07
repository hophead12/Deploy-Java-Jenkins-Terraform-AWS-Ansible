provider "aws"{
  region     = var.region
}


resource "aws_eip" "web"{

  #instance = aws_instance.web.id     # Create elastic IP in aws and attach it on instance web
  network_interface  = aws_network_interface.main.id
  associate_with_private_ip = aws_network_interface.main.private_ip
  tags     = merge(var.common_tag, {Name = "Server IP web-${var.current_environment}"})
}


resource "aws_instance" "web" {
    ami                    = data.aws_ami.latest_ubuntu.id
    instance_type          = var.instance_type
    tags                   = merge(var.common_tag, {Name = "Web-${var.current_environment}-${var.current_version}-${var.current_build}"})
    availability_zone      = data.aws_availability_zones.availability.names[0]
    key_name               = aws_key_pair.generated_key_web.key_name
    
  network_interface {
    network_interface_id = aws_network_interface.main.id
    device_index         = 0
  }
    
  lifecycle {
   create_before_destroy = true # the server will be destroyed after create new server
  }

  depends_on = [
    aws_db_instance.db,
    aws_internet_gateway.gw
  ]
}


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
  username                = "petclinic" # CHANGE!!!!!!!!!!!!!!!!!
  password                = "petclinic"


  vpc_security_group_ids  = [aws_security_group.db.id]
  availability_zone       = data.aws_availability_zones.availability.names[0]

}                    

#resource "aws_instance" "db" {
#    ami                    = data.aws_ami.latest_aws_linux.id
#    instance_type          = var.instance_type
#    vpc_security_group_ids = [aws_security_group.db.id]
#    tags                   = merge(var.common_tag, {Name = "DB-${var.current_environment}-${var.current_version}-${var.current_build}"})
#    availability_zone      = data.aws_availability_zones.availability.names[1] 
#    key_name               = aws_key_pair.generated_key_db.key_name
#  
#  
#  lifecycle {
#  #prevent_destroy = true # the server will not be destroyed 
#  }
#}



resource "aws_security_group" "db" {
  name        = "Security group DB-${var.current_environment}-${var.current_version}"
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
  name        = "Security group Web-${var.current_environment}-${var.current_version}"
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