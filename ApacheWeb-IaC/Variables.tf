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

variable "AvailZone-3" {
  description = "Third availability zone in us-east-1"
  type = string
  default = "us-east-1e"
}

variable "AvailZone-4" {
  description = "Forth availability zone in us-east-1"
  type = string
  default = "us-east-1b"
}

variable "AvailZone-5" {
  description = "Forth availability zone in us-east-1"
  type = string
  default = "us-east-1c"
}

variable "AvailZone-6" {
  description = "Sixth availability zone in us-east-1"
  type = string
  default = "us-east-1a"
}

variable "mykey" {
  default = "akKey"
}

variable "amznlnx2" {
  default = "ami-01c647eace872fc02"
}

variable "instype" {
  default = "t2.micro"
}