resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.enable_dns_hostname
  
  tags =merge(
    var.common_tags,
    var.vpc_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.ig_tags,
    {
        Name = local.resource_name
    }
  ) 
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  availability_zone = local.zone_names[count.index]
  map_public_ip_on_launch = true
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge(
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
        Name = "${local.resource_name}-public-${local.zone_names[count.index]}"  # interpolation , mixing variables and commands
    }
  )
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id = aws_vpc.main.id
    availability_zone = local.zone_names[count.index]
    cidr_block = var.private_subnet_cidrs[count.index]

    tags = merge(
        var.common_tags,
        var.private_subnet_cidr_tags,
        {
            Name = "${local.resource_name}-private-${local.zone_names[count.index]}"  
        }
    ) 
}

resource "aws_subnet" "database" {  # 1st name is database[0] and 2nd name is database[1]
    vpc_id = aws_vpc.main.id
    count = length(var.database_subnet_cidrs)
    availability_zone = local.zone_names[count.index]
    cidr_block = var.database_subnet_cidrs[count.index]

    tags = merge(
        var.common_tags,
        var.private_subnet_cidr_tags,
        {
            Name = "${local.resource_name}-database-${local.zone_names[count.index]}"
        }
    )  
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
      Name = "${local.resource_name}"
    }
  )
}

resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,
    var.ntw_tags,
    {
        Name = local.resource_name
    }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency  
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_table_tags,
    {
        Name = "${local.resource_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_table_tags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "databse" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.databse_route_table_tags,
    {
        Name = "${local.resource_name}-databse"
    }
  )
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.ngw.id
}

resource "aws_route" "databse_route" {
  route_table_id            = aws_route_table.databse.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.ngw.id
}

#route table sub net association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "databse" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = element(aws_subnet.database[*].id, count.index)
  route_table_id = aws_route_table.databse.id
}