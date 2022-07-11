locals {
  config             = try(yamldecode(file("../config.yaml")), {})
  ipaddress_vars     = try(local.config["ipaddress"], [])
  network_vars       = try(local.config["network"], [])
  objectstorage_vars = try(local.config["objectstorage"], [])

}
