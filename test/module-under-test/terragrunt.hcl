# Integration test config for the module under test.
# Replace <group>, <module-name>, and the version constraint to match the module being tested.
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
  source = "tfr://${get_env("CI_SERVER_HOST", "gitlab.com")}/<group>/<module-name>/azurerm?version=~> 1.0"
}

inputs = {
  env      = "test"
  app      = "module-test"
  location = "uksouth"

  resource_group_name    = "rg-test-<module-name>-uksouth"
  server_name            = "test-<module-name>-uksouth"
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
