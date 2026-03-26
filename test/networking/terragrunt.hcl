# Networking dependency for module testing.
# Creates the shared private endpoints subnet in the dev VNet.
# All inputs are flat and explicit — no env.hcl inheritance.

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # Source from registry once published, or git ref during development
  source = "tfr://${get_env("CI_SERVER_HOST", "gitlab.com")}/<group>/networking/azurerm?version=~> 1.0"
}

inputs = {
  env            = "test"
  location       = "uksouth"
  vnet_rg        = "rg-networking-dev-uksouth"
  vnet_name      = "vnet-dev-uksouth"
  address_prefix = "172.19.208.0/27"
}
