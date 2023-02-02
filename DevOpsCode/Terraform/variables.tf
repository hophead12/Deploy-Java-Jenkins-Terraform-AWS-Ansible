variable "region" {
  description = "please enter your variable"
  default = "eu-central-1"
}

variable "instance_type" {
  description = "type instance"
  default     = "t2.micro"
}


variable "allow_ports" {
  description = "list of ports"
  type       = list
  default    = ["80", "443", "8080", "22"] 
}

variable "allow_ports_db" {
  description = "list of ports for db"
  type = list
  default = ["3306", "22"]
}


variable "current_version" {
  description = "current version"
  default = "V1"
}

variable "common_tag" {
  description = "Common Tags to apply to all resources"
  type = map
  default = {
    Owner = "Danylo Bosenko"
    Project = "Demo"
    Environment = "DEV"
  }
}