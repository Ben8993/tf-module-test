# Integration test config for the module under development.
# Replace this file's contents with the module being tested.
# All inputs are flat and explicit — no env.hcl or app.hcl inheritance.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "networking" {
  config_path = "../networking"

  mock_outputs = {
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock/providers/Microsoft.Network/virtualNetworks/mock/subnets/mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

terraform {
  # During development — source from a specific git ref of the module repo.
  # Replace <group>, <module-repo>, and <branch-or-tag>.
  source = "git::https://oauth2:${get_env("CI_JOB_TOKEN", "")}@${get_env("CI_SERVER_HOST", "gitlab.com")}/<group>/<module-repo>.git//.?ref=<branch-or-tag>"

  # Once published to the registry, replace the above with:
  # source = "tfr://${get_env("CI_SERVER_HOST", "gitlab.com")}/<group>/<module-name>/azurerm?version=1.0.0"
}

inputs = {
  # All inputs explicit — no inheritance from parent configs
  env      = "test"
  app      = "module-test"
  location = "uksouth"

  resource_group_name    = "rg-test-<module-name>-uksouth"
  server_name            = "test-<service>-uksouth"
  administrator_login    = "psqladmin"
  administrator_password = get_env("TEST_POSTGRES_ADMIN_PASSWORD", "")

  sku_name   = "B_Standard_B1ms"
  storage_mb = 32768
  databases  = ["testdb"]

  subnet_id = dependency.networking.outputs.subnet_id

  tags = {
    environment = "test"
    managed_by  = "terraform"
    purpose     = "module-testing"
  }
}
