terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}


# Crear VPC
resource "aws_vpc" "tf-VPC-trabajo" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

 tags= {
  Name= "tf-VPC-trabajo"
 }
}


# Crear Subnets (4)
resource "aws_subnet" "tf-subnet-publica-1" {
  vpc_id     = aws_vpc.tf-VPC-trabajo.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "tf-subnet-publica-1"
  }
}

resource "aws_subnet" "tf-subnet-privada-1" {
  vpc_id     = aws_vpc.tf-VPC-trabajo.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "tf-subnet-privada-1"
  }
}

resource "aws_subnet" "tf-subnet-publica-2" {
  vpc_id     = aws_vpc.tf-VPC-trabajo.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "tf-subnet-publica-2"
  }
}

resource "aws_subnet" "tf-subnet-privada-2" {
  vpc_id     = aws_vpc.tf-VPC-trabajo.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "tf-subnet-privada-2"
  }
}


# Crear internet gateway
resource "aws_internet_gateway" "tf-gateway-trabajo" {
  vpc_id = aws_vpc.tf-VPC-trabajo.id

  tags = {
    Name = "tf-gateway-trabajo"
  }
}


################ Crear 2 tablas de rutas (1 pública y 1 privada)

## Tabla pública con association(subnets-publicas)
resource "aws_route_table" "tf-tr-publicas-trabajo" {
  vpc_id = aws_vpc.tf-VPC-trabajo.id
  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.tf-gateway-trabajo.id
  }
  tags = {
    Name = "tf-tr-publicas-trabajo"
  }
  depends_on = [aws_internet_gateway.tf-gateway-trabajo]
}

resource "aws_route_table_association" "publica-1" {
  subnet_id      = aws_subnet.tf-subnet-publica-1.id

  route_table_id = aws_route_table.tf-tr-publicas-trabajo.id
}

resource "aws_route_table_association" "publica-2" {
  subnet_id      = aws_subnet.tf-subnet-publica-2.id

  route_table_id = aws_route_table.tf-tr-publicas-trabajo.id
}


resource "aws_main_route_table_association" "tf-main" {
  vpc_id         = aws_vpc.tf-VPC-trabajo.id
  route_table_id = aws_route_table.tf-tr-publicas-trabajo.id
}


## Tabla privada con association(subnets-privadas)
resource "aws_route_table" "tf-tr-privadas-trabajo" {
  vpc_id = aws_vpc.tf-VPC-trabajo.id

  route = []

  tags = {
    Name = "tf-tr-privadas-trabajo"
  }
}

resource "aws_route_table_association" "privada-1" {
  subnet_id      = aws_subnet.tf-subnet-privada-1.id

  route_table_id = aws_route_table.tf-tr-privadas-trabajo.id
}

resource "aws_route_table_association" "privada-2" {
  subnet_id      = aws_subnet.tf-subnet-privada-2.id

  route_table_id = aws_route_table.tf-tr-privadas-trabajo.id
}

# Key pair (no lo uso)
# resource "tls_private_key" "this" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

resource "aws_key_pair" "tf-key-trabajo" {
  key_name   = "tf-key-trabajo"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9WF1e++G/R8kjptanRK2eq8q42jfu99F2qJVNPKMnlMy1qd5mnkXUDdPvrenLZXDXKNwfwEgY+mmc07qGm5hK7XZzPZ9U/fFp8SOtaKrLl4y9KvhO0CMlCKCglP3GsJrP10DbavSsqRMLfHCJjkUDBNyJ0zXLKyYToCR4DaOXxNa22O6qwbSk0WicAxWhyhO454EDb9urVhFP5R86/zVqiEVGhP8vsUirWIA8jupOU5RVlwaIX8yfV09GS1NkYSVVE2Qfp9B0w1t8yKeS9XhNv1cjd4vwqb+p5kBdpVrBbO3F+t7rRXJsYL0XThpVwY0OqX53DKLsIgNuWVnA5nF5TNMXMcPUAKZB/wUe11i5WVgqZlppA+8injUGWSaFBD6X4Lluf/p5qwrdZ4Cilu//y4vQcPCkt2c7vCRGaAIAM0jfaroStUR6icmjnMSUHm0LEID79otQAtoxhmXcvjaegvFZ/W0LKI+P0LsV7cE8VHyDlLd93FtK4wmguRQi47s= mike@mike-Precision-5550"
  #public_key = file("${path.module}/clave_ssh_terraform.pub")
}

# Crear 3 security groups (1 database MySQL, 1 para instancia WebApp y 1 para el Load Balancer)

# 1º Instancia
resource "aws_security_group" "tf-instancia-trabajo-sg" {
  name        = "tf-instancia-trabajo-sg"
  description = "Grupo de seguridad para instancia WebApp desde terraform"
  vpc_id      = aws_vpc.tf-VPC-trabajo.id

  ingress = [
    {
      description      = ""
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = ""
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },{
      description      = ""
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "tf-GSeg-instancia"
  }
}


# 2º Database
resource "aws_security_group" "tf-database-trabajo-sg" {
  name        = "tf-database-trabajo-sg"
  description = "Grupo de seguridad para database desde terraform"
  vpc_id      = aws_vpc.tf-VPC-trabajo.id

  ingress = [
    {
      description      = ""
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "tf-GSeg-database"
  }
}


# 3º Load Balancer
resource "aws_security_group" "tf-loadbalancer-trabajo-sg" {
  name        = "tf-loadbalancer-trabajo-sg"
  description = "Grupo de seguridad para load balancer desde terraform"
  vpc_id      = aws_vpc.tf-VPC-trabajo.id

  ingress = [
    {
      description      = ""
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = ""
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    Name = "tf-GSeg-loadbalancer"
  }
}


# Crear Subnet group RDS
resource "aws_db_subnet_group" "terraform-sg-mysql-ddbb" {
  name       = "terraform-sg-mysql-ddbb"
  subnet_ids = [aws_subnet.tf-subnet-privada-1.id, aws_subnet.tf-subnet-privada-2.id]
  description = "Subnet Group para database terraform"

}


# Crear RDS instancia MySQL (Está en notas)
resource "aws_db_instance" "tf-trabajo-mysql-db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0.23"
  instance_class       = "db.t2.micro"
  name                 = "MyDB"
  username             = "admin"
  password             = "cocacola1"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  backup_retention_period = 7
  db_subnet_group_name = aws_db_subnet_group.terraform-sg-mysql-ddbb.id
  publicly_accessible  = true
  identifier           = "tf-trabajo-mysql-db"
  vpc_security_group_ids = ["${aws_security_group.tf-database-trabajo-sg.id}"]
}


# Secretos (Mirar en notas el comentario)

# Crear IAM policy
resource "aws_iam_policy" "tf-politica-secretos-trabajo" {
  name        = "tf-politica-secretos-trabajo"
  description = "Política de secretos desde terraform"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "*"
        }
     ]
  })
}


# Crear IAM Role
resource "aws_iam_role" "tf-rol-trabajo" {
  name = "tf-rol-trabajo"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}


# Attach el rol con la policy
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.tf-rol-trabajo.name
  policy_arn = aws_iam_policy.tf-politica-secretos-trabajo.arn
}


# Crear instance profile (para launch template)
resource "aws_iam_instance_profile" "tf-instance-profile" {
  name = "tf-instance-profile"
  role = aws_iam_role.tf-rol-trabajo.name
  depends_on = [
    aws_iam_role_policy_attachment.test-attach
  ]
}


# Crear Target group
resource "aws_lb_target_group" "tf-trabajo-tg" {
  target_type = "instance"
  name     = "tf-trabajo-tg"
  protocol = "HTTP"
  port     = 8080
  vpc_id   = aws_vpc.tf-VPC-trabajo.id
  protocol_version = "HTTP1"
  health_check {
    protocol = "HTTP"
    path = "/api/utils/healthcheck"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout  = 10
    interval = 30
    matcher  = 200
  }
}


# Crear Load Balancer
resource "aws_lb" "tf-trabajo-lb" {
  load_balancer_type = "application"
  name               = "tf-trabajo-lb"
  internal           = false
  ip_address_type    = "ipv4"
  subnet_mapping {
    subnet_id        = aws_subnet.tf-subnet-publica-1.id
  }
  subnet_mapping {
    subnet_id        = aws_subnet.tf-subnet-publica-2.id
  }
  security_groups    = [aws_security_group.tf-loadbalancer-trabajo-sg.id]
  enable_deletion_protection = false
}

# Crear el Listener del load balance
resource "aws_lb_listener" "tf-listener-lb" {
  load_balancer_arn = aws_lb.tf-trabajo-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-trabajo-tg.arn
  }
}


# Crear Launch Template
resource "aws_launch_template" "tf-trabajo-template" {
  name = "tf-trabajo-template"
  description = "Template de la WebApp para trabajo desde terraform"

  image_id = "ami-05cd35b907b4ffe77"
  instance_type = "t2.micro"

  key_name = aws_key_pair.tf-key-trabajo.key_name

  network_interfaces {
    associate_public_ip_address = "true"
    delete_on_termination = "true"
    security_groups = ["${aws_security_group.tf-instancia-trabajo-sg.id}"]
    subnet_id = aws_subnet.tf-subnet-publica-1.id
  }


  iam_instance_profile {
    name = "${aws_iam_instance_profile.tf-instance-profile.name}"
  }

  user_data = "${base64encode(data.template_file.webapp.rendered)}"

}

data "template_file" "webapp"{
  template = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo docker run -d --name rtb -p 8080:8080 vermicida/rtb
EOF
}

resource "aws_autoscaling_group" "tf-trabajo-asg" {
  name                      = "tf-trabajo-asg"
  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  target_group_arns         = [aws_lb_target_group.tf-trabajo-tg.arn]
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.tf-subnet-publica-1.id, aws_subnet.tf-subnet-publica-2.id]
  depends_on = [aws_db_instance.tf-trabajo-mysql-db]

  launch_template {
    id      = aws_launch_template.tf-trabajo-template.id
    version = "$Default"
  }
}
