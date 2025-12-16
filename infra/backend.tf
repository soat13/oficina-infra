terraform {
  backend "s3" {
    bucket = "soatfiap.tf"
    key    = "oficina-infra/terraform.tfstate"
    region = "us-east-1"
  }
}
