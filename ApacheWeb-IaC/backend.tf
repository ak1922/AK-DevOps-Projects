terraform {
  cloud {
    organization = "nodehouse"

    workspaces {
      name = "ApacheIaCWorkspcae"
    }
  }
}

provider "aws" {
region = "us-east-1"
}