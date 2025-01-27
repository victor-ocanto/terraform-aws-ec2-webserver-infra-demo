output "nat-gw-id" {
  value = aws_nat_gateway.nat.id
}

output "igw-id" {
  value = aws_internet_gateway.igw.id
}
