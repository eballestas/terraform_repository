variable "deployment_region_1" {
  type = string
  description = "Deployment zone for resources"
  default = "us-central1"
}

variable "deployment_region_2" {
  type = string
  description = "Deployment zone for resources"
  default = "southamerica-east1"
}

variable "deployment_zone_1" {
  type = string
  description = "Deployment zone for resources"
  default = "us-central1-b"
}

variable "deployment_zone_2" {
  type = string
  description = "Deployment zone for resources"
  default = "southamerica-east1-b"
}

variable "ip_cidr_range_1" {
  type = string
  description = "CIDR range for the subnet"
  default = "10.0.1.0/24"
}

variable "ip_cidr_range_2" {
  type = string
  description = "CIDR range for the subnet"
  default = "10.0.2.0/24"
}

variable "instance_size" {
  type = string
  description = "Instance size, by default is 'e2-small'"
  default = "e2-small"
}

variable "mig_target_size" {
  type = number
  description = "size of the MIG"
  default = 1
}

variable "prefix" {
  type = string
  description = "Prefix value for resources"
  default = "eballest"
}

resource "random_integer" "suffix_1" {
  min = 10000
  max = 99999
}

locals {
  deployment_name = "${var.prefix}-testing-${random_integer.suffix_1.result}"
  tags = ["allow-ssh", "allow-tcp","testing-instance"]
}