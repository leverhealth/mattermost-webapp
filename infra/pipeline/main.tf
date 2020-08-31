terraform {
  required_version = ">= 0.12.18"

  backend "s3" {
    bucket  = "qh-infrastructures"
    key     = "mattermost-webapp/state/pipeline.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

/* Config */

variable "github_token" {
  type = string
}

variable "github_secret" {
  type = string
}

/* Deploy */

module "pipeline" {
  # source = "../../../lever-infra/modules/pipeline"
  source = "git@github.com:leverhealth/lever-infra.git//modules/pipeline?ref=v0.1.7"

  aws_region              = "us-east-2"
  service                 = "mattermost-webapp"
  artifacts_bucket        = "qh-infrastructures"
  github_org              = "leverhealth"
  github_repo             = "mattermost-webapp"
  github_repo_description = "Implements the users API"
  github_token            = var.github_token
  github_secret           = var.github_secret
}

output "ecr_repo" {
  value = module.pipeline.ecr_repo.repository_url
}

output "github_repo" {
  value = module.pipeline.github_repo.html_url
}
