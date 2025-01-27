provider "aws" {
  region = var.region # Specify your AWS region
}

module "vpc" {
  source                    = "./modules/vpc"
  vpc-name                  = "main-vpc"
  cidr-block                = "10.0.0.0/16"
  priv-subnet-name          = "priv-subnet"
  pub-subnet-name           = "pub-subnet"
  subnet-availability-zone  = var.az
  pub-subnet-a-cidr-block     = "10.0.2.0/24"
  pub-subnet-b-cidr-block     = "10.0.3.0/24"
  priv-subnet-cidr-block    = "10.0.1.0/24"
  priv-route-table          = "private-route-table"
  pub-route-table           = "public-route-table"
  nat-gw-id                 = module.gateways.nat-gw-id
  igw-id                    = module.gateways.igw-id
  ip-whitelist-bastion      = var.ip_whitelist_bastion
  region                    = var.region
}

module "gateways" {
  source          = "./modules/gateways"
  igw-name        = "main-igw"
  nat-gw-name     = "main-nat-gateway"
  vpc-id          = module.vpc.vpc-id
  pub-subnet-id   = module.vpc.pub-subnet-a-id

}
 module "ec2" {
  source                  = "./modules/ec2_instances"
  pub-subnet-id           = module.vpc.pub-subnet-a-id
  ec2-bastion-name        = "bastion"
  ec2-webserver-name      = "webserver"
  ami-id                  = "ami-0ac4dfaf1c5c0cce9"
  priv-subnet-id          = module.vpc.priv-subnet-id
  bastion-instance-type   = "t2.micro"
  webserver-instance-type = "t2.micro"
  s3-bucket-name          = "elasticbeanstalk-us-east-1-884694268658"
  ssh-pub-key                 = "aws-ec2"
  bastion-sg              = module.vpc.bastion-sg
  webserver-sg            = module.vpc.webserver-sg
  ssh-pub-key-file        = var.ssh_pub_key_file
 }
 module "load-balancer"{
  source          = "./modules/load_balancer"
  alb-name        = "alb-web-server"
  alb-target-name = "webserver"
  vpc-id          = module.vpc.vpc-id
  pub-subnet-a-id   = module.vpc.pub-subnet-a-id
  pub-subnet-b-id   = module.vpc.pub-subnet-b-id
  alb-sg            = module.vpc.alb-sg
  web-server-id     = module.ec2.web-server-id
 }
