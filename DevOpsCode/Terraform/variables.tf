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
  default = "1"
}
variable "current_build" {
  description = "current build"
  default = "0"
}
variable "current_environment" {
  description = "current env"
  default = "env"
}

variable "common_tag" {
  description = "Common Tags to apply to all resources"
  type = map
  default = {
    Owner = "Danylo Bosenko"
    Project = "Final-Task"
  }
}


variable "usernamedb" {
  description = "The username for the DB master user"
  type        = string
}

variable "passworddb" {
  description = "The password for the DB master user"
  type        = string
}