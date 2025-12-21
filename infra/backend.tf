terraform {
  backend "s3" {
    bucket = "soatfiap-f2"
    key    = "state/terraform.tfstate"
    region = "us-east-1"
  }
}
