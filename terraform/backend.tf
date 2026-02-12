terraform {
  backend "s3" {
    bucket = "matts-terraform-states"
    key    = "sesh-ops/terraform.tfstate"
    region = "us-east-2"

    # Use S3-native state locking (Terraform 1.11+)
    # This eliminates the need for DynamoDB
    use_lockfile = true

    # Explicitly disable DynamoDB locking
    dynamodb_table = null

    # Enable encryption at rest
    encrypt = true
  }
}
