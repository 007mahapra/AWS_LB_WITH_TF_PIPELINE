resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # Change to your desired CIDR block
  tags = {
  Name = "VPC For Load Balancer" }

}

resource "aws_subnet" "pub_subnets" {
  for_each                = { for idx, zone in var.availability_zone : idx => zone }
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.${each.key}.0/24" # Adjust CIDR block as needed
  map_public_ip_on_launch = true
  availability_zone       = each.value
  tags = {
    "Name" = "PUBLIC_SUBNET_${each.value}"
  }
}


resource "aws_subnet" "pvt_subnets" {
  for_each          = { for idx, zone in var.availability_zone : idx => zone }
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.${each.key + 2}.0/24" # Adjust CIDR block as needed
  availability_zone = each.value
  tags = {
    "Name" = "PRIVATE_SUBNET_${each.value}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "INTERNET_GATEWAY"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "LB NAT IP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.pub_subnets[0].id

  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}
