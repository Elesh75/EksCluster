resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "eksvpc"
  }
}


# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id

  tags = {
    Name = "igw"
  }
}

# NatGW
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "NATgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Create EIP 
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    name = "nat"
  }
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.mainvpc.id
  count                   = length(var.public_cidr)
  cidr_block              = element(var.public_cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true

  tags = {
    "Name"                      = "public"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/eks" = "owned"
  }
}

# Private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.mainvpc.id
  count             = length(var.private_cidr)
  cidr_block        = element(var.private_cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)

  tags = {
    "Name"                            = "private"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks"       = "owned"
  }
}

#

# private route-table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.mainvpc.id

  depends_on = [aws_subnet.private]


  tags = {
    Name = "private"
  }
}

# public route-table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mainvpc.id

  depends_on = [aws_subnet.public]


  tags = {
    Name = "public"
  }
}

# private route
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"              #  the code creates a route in an AWS route table with a destination CIDR block of "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.natgw.id # which is a default route. The route directs the traffic to flow through the specified NAT gateway, 
  #  enabling instances in the subnet associated with the route table to reach the internet using the NAT gateway for outbound traffic.

  depends_on = [aws_route_table.private]
}

# public route
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"                 #  the code creates a route in an AWS route table with a destination CIDR block of "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id # which is a default route. The route directs the traffic to flow through the specified NAT gateway, 
  #  enabling instances in the subnet associated with the route table to reach the internet using the NAT gateway for outbound traffic.

  depends_on = [aws_route_table.public]
}

# Private Subnet and Route_Table Association
resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id

  depends_on = [aws_subnet.private, aws_route.private_nat_gateway]
}

# Public Subnet and Route_Table Association
resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  depends_on = [aws_subnet.public, aws_route.public_internet_gateway]
}