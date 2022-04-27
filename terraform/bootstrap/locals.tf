locals {
  config       = try(yamldecode(file("../../config.yaml")), {})
  network_vars = try(local.config["network"], [])
  nosql_vars   = try(local.config["nosql"], [])
}
