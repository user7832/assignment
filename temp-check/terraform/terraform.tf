terraform {
    backend "s3" {
        bucket = "tf-state-hf738jskndj3"
        key = "prom-temp"
        region = "us-east-1"
        encrypt = true
        profile = "default"
    }
}

provider "aws" {
  region = "us-east-1"
  profile = "user2"
}
