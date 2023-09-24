variable "AvailZone-1" {
  description = "First availability zone in us-east-1"
  type = string
  default = "us-east-1d"
}

variable "AvailZone-2" {
  description = "Second availability zone in us-east-1"
  type = string
  default = "us-east-1f"
}

variable "AvailZone-5" {
  description = "Third availability zone in us-east-1"
  type = string
  default = "us-east-1c"
}

variable "AvailZone-6" {
  description = "Forth availability zone in us-east-1"
  type = string
  default = "us-east-1a"
}

variable "mykey" {
  default = "akKey"
  description = "aws key pair to login to instance"
  type = string
}

variable "amznlnx2" {
  default = "ami-01c647eace872fc02"
  description = "Amazon machine image for aws linux hosts"
  type = string
}

variable "instype" {
  description = "Linux instance type"
  type = string
  default = "t2.micro"
}

variable "LoadBalancerCert" {
  description = "Https certificate"
  type = string
  default = "arn:aws:acm:us-east-1:355740888737:certificate/58496ee5-1ea8-4f1f-99e3-67a5fb7f5cfd"
}