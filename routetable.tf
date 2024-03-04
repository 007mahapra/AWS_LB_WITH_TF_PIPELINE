resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Routes"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Routes"
  }
}


resource "aws_route_table_association" "private_routes" {
  for_each          = aws_subnet.pvt_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_routes" {
  for_each          = aws_subnet.pub_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}