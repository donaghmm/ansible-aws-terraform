variable "access_key" {}
variable "secret_key" {}
variable "region"{
 default = "us-east-1"
}
variable "tags"{
 default = "demo"
}
variable "availability_zones" {
  default     = "us-east-1a,us-east-1b,us-east-1c"
}
variable "aws_amis" {
  default = {
"us-east-1" = "ami-01ad357b"
  }
}
variable "instance_type" {
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "3"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "3"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "3"
}
variable "key_name" {

default = "aws-demo"

}
