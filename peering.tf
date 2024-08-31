resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = var.accepter_vpc_id == "" ? data.aws_vpc.default.id : var.accepter_vpc_id
  auto_accept   = var.accepter_vpc_id == "" ? true : false
  vpc_id        = aws_vpc.main.id

  tags = {
    Name = "${local.resource_name}-peering"
  }
}

##adding public-routes to peering ##
resource "aws_route" "public" {
  count = var.is_peering_required && var.accepter_vpc_id == "" ? 1 : 0 
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "private" {
  count = var.is_peering_required && var.accepter_vpc_id == "" ? 1 : 0 
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "database" {
  count = var.is_peering_required && var.accepter_vpc_id == "" ? 1 : 0 
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

##dafault to peering ##
resource "aws_route" "default_peering" {
  count = var.is_peering_required && var.accepter_vpc_id == "" ? 1 : 0 
  route_table_id            = data.aws_route_table.main_route_id.id
  destination_cidr_block    = var.cidr_vpc
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}