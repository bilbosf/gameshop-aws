resource "aws_vpc" "gameshop_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Gameshop VPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.gameshop_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "public-${var.azs[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.gameshop_vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "private-${var.azs[count.index]}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.gameshop_vpc.id
  tags = {
    Name = "Gameshop VPC IG"
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "NAT Gateway"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.gameshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.gameshop_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
