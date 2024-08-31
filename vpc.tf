resource "aws_vpc" "main"{
  cidr_block       = var.cidr_vpc
  instance_tenancy = "default"
  enable_dns_hostnames = var.hostname

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
     
  )
}

##Sigw##
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
{
    Name = local.resource_name
  }
  )
}

##public subnet##
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

##private subnet##
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

##database subnet##
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

##database dubnet group###
resource "aws_db_subnet_group" "db_group" {
  name       = "main"
  subnet_ids = aws_subnet.database[*].id

  tags = {
    Name = "My-DB-subnet-group"
  }
}

##EIP##
resource "aws_eip" "elastic" {
  domain = "vpc"
}

##NAT GW###
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.elastic.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-NAT"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.public]
}

##public route###
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-public-route"
    }
  )
}

##private route###
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-private-route"
    }
  )
}

##database route###
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-database-route"
    }
  )
}

##adding public-routes to igw ##
resource "aws_route" "route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.public.id
}

##adding private-routes to NAT ##
resource "aws_route" "r" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

##adding database-routes to igw ##
resource "aws_route" "routed" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

##public subent associationto routes####
resource "aws_route_table_association" "public_subnet" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

##private subent associationto routes####
resource "aws_route_table_association" "private_subnet" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

## database subent associationto routes####
resource "aws_route_table_association" "database_subnet" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}

## database subent associationto routes####
resource "aws_route_table_association" "default_subnet" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.database.id
}


