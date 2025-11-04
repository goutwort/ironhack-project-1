provider "aws" {
  alias  = "dublin"
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "tiffany-terraform-state-bucket"  # Replace with your actual S3 bucket name
    key            = "terraform.tfstate"          # The file path to store the state
    region         = "eu-west-1"                  # Your AWS region
    encrypt        = true                         # Encrypt state file at rest
    # dynamodb_table = "tiffany-terraform-state-lock"       # DynamoDB table for state locking
    use_lockfile   = true
  }
}