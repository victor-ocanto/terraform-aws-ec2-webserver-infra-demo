variable "ami-id" {
  type = string
}

variable "ec2-bastion-name" {
  type = string
}

variable "ec2-webserver-name" {
  type = string
}

variable "pub-subnet-id" {
  type = string

}

variable "priv-subnet-id" {
  type = string

}

variable "bastion-instance-type" {
  type = string

}
variable "webserver-instance-type" {
  type = string

}
variable "s3-bucket-name" {
  type = string
}

variable "ssh-pub-key" {
  type = string
}
variable "ssh-pub-key-file" {
  type =string
}
variable "bastion-sg" {
  type = string
}
variable "webserver-sg" {
  type = string
}
