terraform {
  source = "git::https://github.com/organization/terraform-modules.git"
}

locals {
  environment = "production"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  region = "us-west-2"
}

dependency "vpc" {
  config_path = "../vpc"
}