locals {
  project_id               = "eballest-sandbox"
  gcp_service_account_name = "${var.prefix}-votr-app"
  cloud_sql_instance_name  = "${random_id.id.hex}-db"
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = var.prefix
}

variable "prefix" {
  type        = string
  description = "Prefix for naming the project and other resources"
  default     = "votr"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "project_id" {
  type    = string
  default = "eballest-sandbox"
}

variable "network_name" {
  type    = string
  default = "votr-network"
}

variable "subnet_name" {
  type    = string
  default = "votr-subnet"
}

variable "subnet_ip" {
  type    = string
  default = "10.10.10.0/24"
}

variable "database_version" {
  type        = string
  description = "Database version for app"
  default     = "MYSQL_5_7"
}

variable "database_tier" {
  type        = string
  description = "Database tier for app"
  default     = "db-f1-micro"
}

variable "database_name" {
  type        = string
  description = "Name of database for app"
  default     = "votr"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-1"
}

variable "instance_name" {
  type        = string
  description = "The gce instance name"
  default     = "votr"
}

variable "target_size" {
  type        = number
  description = "The number of runner instances"
  default     = 1
}

variable "cooldown_period" {
  type        = number
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  default     = 60
}

variable "source_image" {
  type        = string
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Ubuntu image."
  default     = "ubuntu-minimal-1804-lts"
}

variable "source_image_family" {
  type        = string
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Ubuntu image."
  default     = "ubuntu-minimal-1804-lts"
}

variable "source_image_project" {
  type        = string
  description = "Project where the source image comes from"
  default     = "ubuntu-os-cloud"
}





