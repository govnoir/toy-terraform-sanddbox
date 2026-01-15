provider "aws" {
  region                      = "eu-north-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3    = "http://localhost:4566"
    ec2   = "http://localhost:4566"
    ecs   = "http://localhost:4566"
    iam   = "http://localhost:4566"
    elbv2 = "http://localhost:4566"
    logs  = "http://localhost:4566"
    rds   = "http://localhost:4566"
  }

  default_tags {
    tags = {
      Environment = "Local"
      Service     = "LocalStack"
    }
  }
}
