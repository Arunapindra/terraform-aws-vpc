variable "project_name" {
    type = string 
}

variable "environment" {
    type = string 
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
    default = true 
}
 variable "common_tags" {
    default = {
        terraform = "true"
    }
 }
 variable "vpc_tags" {
   default = {}
 }
 variable "igw_tags" {
  default = {}
}
variable "public_subnet_cidrs" {
  type = list(string)
  validation {
    condition = length(var.public_subnet_cidrs) == 2
    error_message = "please provide 2 valid public subnet cidrs"
  }
}
variable "private_subnet_cidrs" {
  type = list(string)
  validation {
    condition = length(var.private_subnet_cidrs) == 2
    error_message = "please provide 2 valid private subnet cidrs"
  }
}
variable "database_subnet_cidrs" {
  type = list(string)
  validation {
    condition = length(var.database_subnet_cidrs) == 2
    error_message = "please provide 2 valid database subnet cidrs"
  }
}
variable "public_subnet_tags" {
  default = {}
}
variable "private_subnet_tags" {
  default = {}
}
variable "database_subnet_tags" {
  default = {}
}
variable "nat_gateway_tags" {
  default = {}
}