output "az_info"{
    value = data.aws_availability_zones.available.names
}

output "vpc_default_id"{
    value = data.aws_vpc.default.id
}

output "public_subnet_id"{
    value = aws_subnet.public[*].id
}