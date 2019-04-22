variable "vpc_cidr" {
  description = "CIDR block for the vpc"
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnet_ips" {
  type    = "list"
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnet_names" {
  type    = "list"
  default = ["dz-public-subnet-1", "dz-public-subnet-2", "dz-public-subnet-3"]
}

variable "vpc_private_subnet_ips" {
  type    = "list"
  default = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}

variable "vpc_private_subnet_names" {
  type    = "list"
  default = ["dz-private-subnet-1", "dz-private-subnet-2", "dz-private-subnet-3"]
}

variable "vpc_subnet_azs" {
  type    = "list"
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "allocation_id" {
  description = "Elastic IP address for NAT gateway"
  default     = "eipalloc-08e0d70bda7d5e75a"
}

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "AWS profile"
  default     = "teststudent21"
}

variable "worker_ami_id" {
  description = "eu-west-1 eks optimised AMI id for the worker nodes"
  default     = "ami-098fb7e9b507904e7"
}
