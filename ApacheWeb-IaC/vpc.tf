resource "aws_vpc" "ApacheApp-vpc" {
    cidr_block = "172.32.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "ApacheServ-vpc"
    }
}

resource "aws_subnet" "ApacheAppVPC-PublicSubnet1" {
  vpc_id = aws_vpc.ApacheApp-vpc.id
  availability_zone = var.AvailZone-1
  cidr_block = "172.32.0.0/18"
  map_public_ip_on_launch = true

  tags = {
    Name = "ApacheAppVPC-PublicSubnet1"
  }
}

resource "aws_subnet" "ApacheAppVPC-PrivateSubnet1" {
  vpc_id = aws_vpc.ApacheApp-vpc.id
  availability_zone = var.AvailZone-2
  cidr_block = "172.32.64.0/18"
  map_public_ip_on_launch = false

    tags = {
    Name = "ApacheAppVPC-PrivateSubnet1"
  }
}

resource "aws_subnet" "ApacheAppVPC-PublicSubnet2" {
  vpc_id = aws_vpc.ApacheApp-vpc.id
  availability_zone = var.AvailZone-5
  cidr_block = "172.32.128.0/18"
  map_public_ip_on_launch = true

    tags = {
    Name = "ApacheAppVPC-PublicSubnet2"
  }
}

resource "aws_subnet" "ApacheAppVPC-PrivateSubnet2" {
  vpc_id = aws_vpc.ApacheApp-vpc.id
  availability_zone = var.AvailZone-6
  cidr_block = "172.32.192.0/18"
  map_public_ip_on_launch = false

      tags = {
    Name = "ApacheAppVPC-PrivateSubnet2"
  }
}

resource "aws_route_table" "ApacheAppVPC-PublicRouteTable" {
  vpc_id = aws_vpc.ApacheApp-vpc.id

  tags = {
    Name = "ApacheAppVPC-PublicRouteTable"
  }
}

resource "aws_route_table" "ApacheAppVPC-PrivateRouteTable" {
  vpc_id = aws_vpc.ApacheApp-vpc.id

  tags = {
    Name = "ApacheAppVPC-PrivateRouteTable"
  }
}

resource "aws_route_table_association" "PublicSubnet1-Assoc" {
  subnet_id = aws_subnet.ApacheAppVPC-PublicSubnet1.id
  route_table_id = aws_route_table.ApacheAppVPC-PublicRouteTable.id
}

resource "aws_route_table_association" "PublicSubnet2-Assoc" {
  subnet_id = aws_subnet.ApacheAppVPC-PublicSubnet2.id
  route_table_id = aws_route_table.ApacheAppVPC-PublicRouteTable.id
}

resource "aws_route_table_association" "PrivateSubnet1-Assc" {
  subnet_id = aws_subnet.ApacheAppVPC-PrivateSubnet1.id
  route_table_id = aws_route_table.ApacheAppVPC-PrivateRouteTable.id
}

resource "aws_route_table_association" "PrivateSubnet2-Assc" {
  subnet_id = aws_subnet.ApacheAppVPC-PrivateSubnet2.id
  route_table_id = aws_route_table.ApacheAppVPC-PrivateRouteTable.id
}

resource "aws_internet_gateway" "ApacheAppVPC-InternetGateway" {
  vpc_id = aws_vpc.ApacheApp-vpc.id

  tags = {
    Name = "ApacheAppVPC-InternetGateway"
  }
}

resource "aws_route" "ApacheAppVPC-InternetGateway-Route" {
  route_table_id = aws_route_table.ApacheAppVPC-PublicRouteTable.id
  gateway_id = aws_internet_gateway.ApacheAppVPC-InternetGateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_eip" "ApacheAppVPC-ElasticIP" {
  tags = {
    Name = "ApacheAppVPC-ElasticIP"
  }
}

resource "aws_nat_gateway" "ApacheAppVPC-NatGateway" {
  subnet_id = aws_subnet.ApacheAppVPC-PublicSubnet1.id
  allocation_id = aws_eip.ApacheAppVPC-ElasticIP.id

  tags = {
    Name = "ApacheAppVPC-NatGateway"
  }
}

resource "aws_route" "ApacheAppVPC-NatGateway-Route" {
  route_table_id = aws_route_table.ApacheAppVPC-PrivateRouteTable.id
  gateway_id = aws_nat_gateway.ApacheAppVPC-NatGateway.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "ApacheAppVPC-BastionHost-SecGrp" {
  name = "ApacheAppVPC-BastionHost-SecGrp"
  description = "Security group for Bastion host to allow ssh"
  vpc_id = aws_vpc.ApacheApp-vpc.id

  ingress {
    description = "Allow SSH on port 22"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ApacheAppVPC-LoadBalancer-SecGrp" {
    name = "ApacheAppVPC-LoadBalancer-SecGrp"
    description = "Security group for Apache target group for port 80 and 443"
    vpc_id = aws_vpc.ApacheApp-vpc.id

    ingress {
      description = "Allow ssh for target group hosts"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
      description = "Allow http traffic for this security group"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
      description = "Allow https traffic for this security group"
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ApacheAppVPC-ec2-SecGrp" {
    name = "ApacheAppVPC-ec2-SecGrp"
    description = "Allow inboud from ALB only"
    vpc_id = aws_vpc.ApacheApp-vpc.id

    ingress {
      from_port = 0
      to_port = 0
      protocol = -1
      security_groups = [ aws_security_group.ApacheAppVPC-LoadBalancer-SecGrp ]
    }

    ingress {
      description = "Allow SSH on port 22"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}