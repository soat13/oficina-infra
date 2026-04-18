terraform {
  backend "s3" {
    bucket = "soatfiap-4"
    key    = "state/oficina-infra/terraform.tfstate"
    region = "us-east-1"
  }
}
