variable "region" {
  default     = "us-east-1"
  description = "AWS Region"
}

variable "az" {
  default     = "us-east-1a"
}

variable "ip_whitelist_bastion" {
  type = list(string)
}

variable "ssh_pub_key_file" {
  type = string
}
