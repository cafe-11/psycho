data "aws_availability_zones" "available" {}

resource "aws_vpc" "weekday_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "weekday_vpc"
  }
 lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "weekday_internet_gateway" {
  vpc_id = aws_vpc.weekday_vpc.id

  tags = {
    Name = "weekday_internet_gateway"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.weekday_vpc.id

 tags = {
    Name = "public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.weekday_internet_gateway.id
}


resource "aws_default_route_table" "private_rt" {
  default_route_table_id = aws_vpc.weekday_vpc.default_route_table_id

  tags = {
    Name = "private_rt"
  }
}


resource "aws_subnet" "public_test_subnet" {
  count                   = 2
  //count                   = length(var.public_cidrs)
  vpc_id                  = aws_vpc.weekday_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "public_test_subnet"
  }
}


resource "aws_subnet" "private_test_subnet" {
  count                   = 2
  //count                   = length(var.private_cidrs)
  vpc_id                  = aws_vpc.weekday_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private_test_subnet"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count                   = 2
  subnet_id      = aws_subnet.public_test_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_route_table_association" "private_subnet_association" {
  count                   = 2
  subnet_id      = aws_subnet.private_test_subnet.*.id[count.index]
  route_table_id = aws_default_route_table.private_rt.id
}
