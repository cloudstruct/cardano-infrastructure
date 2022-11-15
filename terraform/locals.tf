locals {
  config = try(yamldecode(file("../config.yaml")), {})

  default_tags = try(local.config["default_tags"], {})

  ipaddress_vars     = try(local.config["ipaddress"], [])
  network_vars       = try(local.config["network"], [])
  objectstorage_vars = try(local.config["objectstorage"], [])
  vm_vars            = try(local.config["virtual_machines"], [])

  bootstrap_bucket = try([for os in local.objectstorage_vars : os if try(os.bootstrap, false)][0], false)
}
