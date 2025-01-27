# Primary Network Interface in Public Subnet
resource "aws_network_interface" "bastion_public_eni" {
  subnet_id       = var.pub-subnet-id
  security_groups = [var.bastion-sg]

  tags = {
    Name = "bastion-public-eni"
  }
}

# Secondary Network Interface in Private Subnet
resource "aws_network_interface" "bastion_private_eni" {
  subnet_id       = var.priv-subnet-id
  security_groups = [var.bastion-sg]

  tags = {
    Name = "bastion-private-eni"
  }
}

resource "aws_network_interface" "webserver_private_eni" {
  subnet_id       = var.priv-subnet-id
  security_groups = [var.webserver-sg]

  tags = {
    Name = "webserver-private-eni"
  }
}


# Create an Elastic IP for the Bastion host
resource "aws_eip" "bastion_eip" {
  domain = "vpc"

  tags = {
    Name = "bastion-eip"
  }
}

# Associate the Elastic IP with the Bastion host's primary network interface
resource "aws_eip_association" "bastion_eip_association" {
  allocation_id        = aws_eip.bastion_eip.id
  network_interface_id = aws_network_interface.bastion_public_eni.id
}

resource "aws_instance" "bastion" {
  ami           = var.ami-id
  instance_type = var.bastion-instance-type
  tags = {
    Name = "bastion-host"
  }

  network_interface {
  network_interface_id = aws_network_interface.bastion_public_eni.id
  device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.bastion_private_eni.id
    device_index = 1
  }
  user_data = <<-EOT
    #!/bin/bash
    mkdir -p /home/ec2-user/.ssh
    echo '${file(var.ssh-pub-key-file)}' > /home/ec2-user/.ssh/aws-ec2.pem
    chmod 400 /home/ec2-user/.ssh/aws-ec2.pem
    chown -R ec2-user:ec2-user /home/ec2-user/.ssh
  EOT
  provisioner "remote-exec" {
    inline = [
      "echo 'Welcome to Bastion Host!' | sudo tee /etc/motd > /dev/null"
    ]
     connection {
      type        = "ssh"
      host        = aws_eip.bastion_eip.public_ip
      user        = "ec2-user"
      private_key = file(var.ssh-pub-key-file) # Replace with your private key path
    }
  }

  key_name = var.ssh-pub-key
}

resource "aws_instance" "web_server" {
  ami           = var.ami-id
  instance_type = var.webserver-instance-type

  network_interface {
    network_interface_id = aws_network_interface.webserver_private_eni.id
    device_index         = 0
  }
  user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd aws-cli
  systemctl start httpd
  systemctl enable httpd
  sudo aws s3 cp s3://"${var.s3-bucket-name}"/index.html /var/www/html/index.html
  sudo chmod 644 /var/www/html/index.html
  sudo chown apache:apache /var/www/html/index.html
  EOF

  tags = {
    Name = "web-server"
  }

  iam_instance_profile = aws_iam_instance_profile.web_server_profile.name
  key_name = var.ssh-pub-key
}

resource "aws_iam_role" "web_server_role" {
  name = "web-server-role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "web_server_policy" {
  name = "web-server-policy"
  role = aws_iam_role.web_server_role.id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::${var.s3-bucket-name}/*"
      }
    ]
  }
  EOF
}

resource "aws_iam_instance_profile" "web_server_profile" {
  name = "web-server-instance-profile"
  role = aws_iam_role.web_server_role.name
}
