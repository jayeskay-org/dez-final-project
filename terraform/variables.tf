locals {
  data_lake_bucket = "data-lake"
}

variable "region" {
  description = "Region for AWS resources. Choose as per your location: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html."
  type = string
  default = "us-west-2"
}

variable "profile" {
  description = "Profile to use when building AWS infrastructure--should point to IAM user credentials used for DEZ organization (not root)."
  type = string
  default = "dez_project"
}

variable "project" {
  description = "Name of project."
  type = string
  default = "dez2024-project"
}

variable "local_ip_address" {
  description = "IP address of local machine."
  type = list(string)
  default = ["72.216.124.122/32"]
}

variable "key_name" {
  description = "Name of public-private key pair for SSH access to EC2 instance."
  type = string
  default = "deploy-key"
}

variable "network_security_group_name" {
  description = "value"
  type = string
  default = "ec2 security group"
}
