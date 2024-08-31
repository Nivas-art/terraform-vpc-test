data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = "true"
}

data "aws_route_table" "main_route_id"{
  vpc_id = data.aws_vpc.default.id

  filter {
    name = "association.main"
    values = ["true"]
  }
}