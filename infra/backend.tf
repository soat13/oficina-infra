terraform {
  backend "s3" {
    bucket = "soatfiap-2"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}
