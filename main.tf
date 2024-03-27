resource "aws_vpc" "fiap_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "dev"
  }

}

resource "aws_subnet" "fiap_public_subnet" {
  vpc_id                  = aws_vpc.fiap_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "fiap_igw" {
  vpc_id = aws_vpc.fiap_vpc.id
  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "fiap_public_route_table" {
  vpc_id = aws_vpc.fiap_vpc.id
  tags = {
    Name = "dev-public-route-table"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.fiap_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fiap_igw.id

}

resource "aws_route_table_association" "fiap_public_subnet_association" {
  subnet_id      = aws_subnet.fiap_public_subnet.id
  route_table_id = aws_route_table.fiap_public_route_table.id
}

resource "aws_security_group" "fiap_public_sg" {
  name   = "DEV-sg"
  vpc_id = aws_vpc.fiap_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dev-sg"
  }
}

resource "aws_key_pair" "fiap_auth" {
  key_name   = "fiap-key"
  public_key = file("~/.ssh/mtckey.pub")
}

resource "aws_instance" "fiap_public_ec2" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.fiap_auth.id
  subnet_id              = aws_subnet.fiap_public_subnet.id
  vpc_security_group_ids = [aws_security_group.fiap_public_sg.id]
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "dev-ec2"
  }

  provisioner "local-exec" {
    command = templatefile("windows-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      IdentityFile = "~/.ssh/mtckey"
    })
    interpreter = ["Powershell", "-Command"]
  }
}

