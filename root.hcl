# =============================================================================
# Root Terragrunt config for module integration testing.
#
# This is a standalone project — it has no dependency on the infrastructure
# deployment repo. Modules are sourced directly from the GitLab Terraform
# Module Registry or from a specific git ref during development.
#
# State is stored in this project's GitLab-managed HTTP backend.
# =============================================================================

locals {
  gitlab_api_url    = get_env("CI_API_V4_URL", "https://gitlab.com/api/v4")
  gitlab_project_id = get_env("CI_PROJECT_ID", "0")

  # State key is derived from the module directory path, e.g. "test-networking"
  state_name    = replace(path_relative_to_include(), "/", "-")
  state_address = "${local.gitlab_api_url}/projects/${local.gitlab_project_id}/terraform/state/${local.state_name}"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "azurerm" {
      features {}
      subscription_id = "${get_env("ARM_SUBSCRIPTION_ID", "")}"
    }
  EOF
}

remote_state {
  backend = "http"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    address        = local.state_address
    lock_address   = "${local.state_address}/lock"
    unlock_address = "${local.state_address}/lock"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
    username       = "gitlab-ci-token"
    password       = get_env("CI_JOB_TOKEN", "")
  }
}
