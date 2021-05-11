terraform {
    backend "local" {
        path = "temp-check.tfstate"
    }
}

provider "aws" {
  region = "us-east-1"
  profile = "user2"
}
