output "pub-subnet-a-id" {
  value = aws_subnet.public_subnet_a.id
}
output "pub-subnet-b-id" {
  value = aws_subnet.public_subnet_b.id
}


output "vpc-id" {
  value = aws_vpc.main.id
}

output "priv-subnet-id" {
  value = aws_subnet.private_subnet.id

}

output "bastion-sg" {
  value = aws_security_group.bastion_sg.id
}

output "webserver-sg" {
  value = aws_security_group.web_server_sg.id
}

output "alb-sg" {
  value = aws_security_group.alb_sg.id
}
