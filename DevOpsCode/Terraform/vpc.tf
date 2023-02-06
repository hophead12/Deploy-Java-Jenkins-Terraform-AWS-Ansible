resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/24"
    default_route_table_id  = aws_route_table.route.id
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags = merge(var.common_tag, {Name = "VPC-Petclinic-${var.current_environment}-${var.current_version}"})
}

resource "aws_internet_gateway" "gw" {
  aws_vpc = aws_vpc.main.id
  tags = merge(var.common_tag, {Name = "GateWay-Petclinic-${var.current_environment}-${var.current_version}"})
}

resource "aws_route_table" "route" {


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(var.common_tag, {Name = "Route-Petclinic-${var.current_environment}-${var.current_version}"})
}
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.availability.names[0]
  cidr_block = "10.0.0.0/25"
  tags = merge(var.common_tag, {Name = "Subnet-Petclinic-${var.current_environment}-${var.current_version}"})
  
  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_subnet" "main2" {
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.availability.names[1]
  cidr_block = "10.0.0.128/25"
  tags = merge(var.common_tag, {Name = "Subnet2-Petclinic-${var.current_environment}-${var.current_version}"})
  
  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_network_interface" "main" {
  subnet_id         = aws_subnet.main.id
  private_ips       = ["10.0.0.100"]
  security_groups   = [aws_security_group.web.id]
  tags              = merge(var.common_tag, {Name = "Interface-Petclinic-${var.current_environment}-${var.current_version}"})
}


resource "aws_db_subnet_group" "main" {
  name            = "main"
  subnet_ids      = [aws_subnet.main.id, aws_subnet.main2.id]
  tags            = merge(var.common_tag, {Name = "DB-SubnetGroup-Petclinic-${var.current_environment}-${var.current_version}"})
}