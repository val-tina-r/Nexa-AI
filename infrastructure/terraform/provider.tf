terraform {
  backend "s3" {
    bucket = "nexa-ai-terraform-state-g3"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}