#creating vpc with cidr of 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
    enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}
#creating internet gateway and attach to vpc
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,var.igw_tags,
    {
        Name = local.resource_name
    }
  )
}
# subnets creation 
# i want 2 availability zones in 2 regions us-east-1a and us-east-1b
# they are 
#public 1b,1b--> 10.0.1.0/24 ; 10.0.2.0/24
#private 1a,1b--> 10.0.11.0/24;10.0.12.0/24
#database 1a,1b--> 10.0.21.0/24;10.0.22.0/24
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,var.public_subnet_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,var.private_subnet_tags,
    {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
  tags = merge(
    var.common_tags,var.database_subnet_tags,
    {
        Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}
#DATABASE SUBNET GROUP FOR RDS
resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,{
    Name = "My DB subnet group"
  }
  )
  
}
resource "aws_eip" "nat" {
  domain   = "vpc"
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags, var.nat_gateway_tags,
    {
    Name = "gw NAT"
  }

  )
 
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}