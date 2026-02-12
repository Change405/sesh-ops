provider "aws" {
  region = "us-east-2"
  # AWS provider is only used for S3 backend state storage
  # Region is hardcoded to match backend configuration in backend.tf
}

provider "hcloud" {
  # Token is read from HCLOUD_TOKEN environment variable
}
