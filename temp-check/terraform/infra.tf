data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "monitoring_sg" {
    name        = "sg_monitoring_server"
    description = "Allow connect to Grafana and Prometheus"

    ingress {
        description      = "SSH"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "Prometheus"
        from_port        = 9090
        to_port          = 9090
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        description      = "Grafana"
        from_port        = 3000
        to_port          = 3000
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    tags = {
        app = "prom-temp"
    }
}

resource "aws_instance" "monitoring_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  user_data = templatefile(
    "userdata.sh.tmpl",
    {
      we_apikey = var.we_apikey,
      we_city = var.we_city
    }
  )

  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
  key_name = var.key_name

  tags = {
    app = "prom-temp"
  }
}
