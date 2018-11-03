
variable "ssh_key_private" {
  type = "string"
  default = "~/.ssh/liams_key.pem"
}

variable "instance_type" {
  type = "string"
  default = "t3.small"
}
