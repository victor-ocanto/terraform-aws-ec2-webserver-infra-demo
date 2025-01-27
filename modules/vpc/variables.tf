variable "vpc-name" {
  type = string

}
variable "cidr-block" {
  type = string
}
variable "priv-subnet-name" {
  type = string
}

variable "pub-subnet-name" {
  type = string
}

variable "subnet-availability-zone" {
  type = string
}

variable "pub-subnet-a-cidr-block" {
  type = string
}
variable "pub-subnet-b-cidr-block" {
  type = string
}

variable "priv-subnet-cidr-block" {
  type = string
}

variable "priv-route-table" {
  type = string
}
variable "pub-route-table" {
  type = string
}

variable "nat-gw-id" {
  type = string
}
variable "igw-id" {
  type = string
}
variable "ip-whitelist-bastion" {
}
variable "region" {
  type = string
}
