variable "cardano_port" {
  type    = number
  default = 3001
  validation {
    condition     = var.cardano_port > 1023 && var.cardano_port < 65536
    error_message = "ERROR: var.cardano_port has an invalid port specified!"
  }
}
