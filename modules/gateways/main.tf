resource "aws_internet_gateway" "igw" {
  vpc_id            = var.vpc-id
  tags = {
    Name = var.igw-name
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id     = aws_eip.nat_eip.id
  subnet_id         = var.pub-subnet-id

  tags = {
    Name = var.nat-gw-name
  }
}
