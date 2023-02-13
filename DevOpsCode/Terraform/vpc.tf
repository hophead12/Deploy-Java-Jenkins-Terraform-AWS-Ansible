resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
    
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = merge(var.common_tag, {Name = "VPC-Petclinic-${var.current_environment}-V${var.current_version}"})
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tag, {Name = "GateWay-Petclinic-${var.current_environment}-V${var.current_version}"})

}


resource "aws_main_route_table_association" "main" {
  vpc_id = aws_vpc.main.id
  route_table_id = aws_route_table.route.id
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(var.common_tag, {Name = "Route-Petclinic-${var.current_environment}-V${var.current_version}"}) 
}

#===========================Subnets==========================================

resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.availability.names[0]
  cidr_block = "10.0.0.0/26"
  map_public_ip_on_launch = true
  tags = merge(var.common_tag, {Name = "Subnet-Petclinic-${var.current_environment}-V${var.current_version}"})
}
resource "aws_subnet" "main2" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.availability.names[1]
  cidr_block = "10.0.0.64/26"
  map_public_ip_on_launch = true
  tags = merge(var.common_tag, {Name = "Subnet2-Petclinic-${var.current_environment}-V${var.current_version}"})
}
resource "aws_subnet" "main3" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.availability.names[2]
  cidr_block = "10.0.0.128/26"
  map_public_ip_on_launch = true
  tags = merge(var.common_tag, {Name = "Subnet3-Petclinic-${var.current_environment}-V${var.current_version}"})
}

resource "aws_db_subnet_group" "main" {
  name            = "main"
  subnet_ids      = [aws_subnet.main.id, aws_subnet.main2.id, aws_subnet.main3.id]
  tags            = merge(var.common_tag, {Name = "DB-SubnetGroup-Petclinic-${var.current_environment}-V${var.current_version}"})

  depends_on = [
    aws_subnet.main,
    aws_subnet.main2,
    aws_subnet.main3
  ]
}