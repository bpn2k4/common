terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.50.0"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id                = data.aws_caller_identity.current.account_id
  region                    = "ap-southeast-1"
  availability_zone_1a      = "${local.region}a"
  availability_zone_1b      = "${local.region}b"
  name                      = "dev-vs-sgp"
  vpc_cidr                  = "10.253.0.0/20"
  public_subnet_1a          = "10.253.0.0/26"
  public_subnet_1b          = "10.253.0.64/26"
  private_data_subnet_1a    = "10.253.1.0/26"
  private_data_subnet_1b    = "10.253.1.64/26"
  private_managed_subnet_1a = "10.253.2.0/26"
  private_managed_subnet_1b = "10.253.2.64/26"
  intra_shared_subnet_1a    = "10.253.3.0/26"
  intra_shared_subnet_1b    = "10.253.3.64/26"
  private_app_subnet_1a     = "10.253.8.0/22"
  private_app_subnet_1b     = "10.253.12.0/22"
  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

provider "aws" {
  region = local.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    {
      Name = "${local.name}-vpc"
    },
    local.tags,
  )
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "${local.name}-default-sg"
    },
    local.tags,
  )
}

resource "aws_subnet" "public_subnet_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public_subnet_1a
  availability_zone = local.availability_zone_1a
  tags = merge(
    {
      Name = "${local.name}-public-1a"
    },
    local.tags,
  )
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public_subnet_1b
  availability_zone = local.availability_zone_1b
  tags = merge(
    {
      Name = "${local.name}-public-1b"
    },
    local.tags,
  )
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "${local.name}-igw"
    },
    local.tags,
  )
}

resource "aws_route_table" "public_rt_1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(
    {
      Name = "${local.name}-public-rt-1a"
    },
    local.tags,
  )
}

resource "aws_route_table" "public_rt_1b" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = merge(
    {
      Name = "${local.name}-public-rt-1b"
    },
    local.tags,
  )
}

resource "aws_route_table_association" "public_rt_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_rt_1a.id
}

resource "aws_route_table_association" "public_rt_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_rt_1b.id
}

resource "aws_subnet" "private_app_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_app_subnet_1a
  availability_zone = local.availability_zone_1a
  tags = merge(
    {
      Name = "${local.name}-private-app-1a"
    },
    local.tags,
  )
}

resource "aws_subnet" "private_app_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_app_subnet_1b
  availability_zone = local.availability_zone_1b
  tags = merge(
    {
      Name = "${local.name}-private-app-1b"
    },
    local.tags,
  )
}

resource "aws_subnet" "private_managed_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_managed_subnet_1a
  availability_zone = local.availability_zone_1a
  tags = merge(
    {
      Name = "${local.name}-private-managed-1a"
    },
    local.tags,
  )
}

resource "aws_subnet" "private_managed_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_managed_subnet_1b
  availability_zone = local.availability_zone_1b
  tags = merge(
    {
      Name = "${local.name}-private-managed-1b"
    },
    local.tags,
  )
}

resource "aws_eip" "nat_ip_1a" {
  domain = "vpc"
  tags = merge(
    {
      Name = "${local.name}-nat-ip-1a"
    },
    local.tags,
  )
}

resource "aws_eip" "nat_ip_1b" {
  domain = "vpc"
  tags = merge(
    {
      Name = "${local.name}-nat-ip-1b"
    },
    local.tags,
  )
}

resource "aws_nat_gateway" "nat_gw_1a" {
  allocation_id = aws_eip.nat_ip_1a.id
  subnet_id     = aws_subnet.public_subnet_1a.id
  tags = merge(
    {
      Name = "${local.name}-nat-gw-1a"
    },
    local.tags,
  )
}

resource "aws_nat_gateway" "nat_gw_1b" {
  allocation_id = aws_eip.nat_ip_1b.id
  subnet_id     = aws_subnet.public_subnet_1b.id
  tags = merge(
    {
      Name = "${local.name}-nat-gw-1b"
    },
    local.tags,
  )
}

resource "aws_route_table" "private_app_rt_1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1a.id
  }
  tags = merge(
    {
      Name = "${local.name}-private-rt-1a"
    },
    local.tags,
  )
}

resource "aws_route_table" "private_app_rt_1b" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1b.id
  }
  tags = merge(
    {
      Name = "${local.name}-private-rt-1b"
    },
    local.tags,
  )
}

resource "aws_route_table" "private_managed_rt_1a" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1a.id
  }
  tags = merge(
    {
      Name = "${local.name}-private-managed-rt-1a"
    },
    local.tags,
  )
}

resource "aws_route_table" "private_managed_rt_1b" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1b.id
  }
  tags = merge(
    {
      Name = "${local.name}-private-managed-rt-1b"
    },
    local.tags,
  )
}

resource "aws_route_table_association" "private_app_rt_1a" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private_app_rt_1a.id
}

resource "aws_route_table_association" "private_app_rt_1b" {
  subnet_id      = aws_subnet.private_app_1b.id
  route_table_id = aws_route_table.private_app_rt_1b.id
}

resource "aws_route_table_association" "private_managed_rt_1a" {
  subnet_id      = aws_subnet.private_managed_1a.id
  route_table_id = aws_route_table.private_managed_rt_1a.id
}

resource "aws_route_table_association" "private_managed_rt_1b" {
  subnet_id      = aws_subnet.private_managed_1b.id
  route_table_id = aws_route_table.private_managed_rt_1b.id
}

resource "aws_subnet" "private_data_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_data_subnet_1a
  availability_zone = local.availability_zone_1a
  tags = merge(
    {
      Name = "${local.name}-private-data-1a"
    },
    local.tags,
  )
}

resource "aws_subnet" "private_data_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private_data_subnet_1b
  availability_zone = local.availability_zone_1b
  tags = merge(
    {
      Name = "${local.name}-private-data-1b"
    },
    local.tags,
  )
}

resource "aws_route_table" "private_data_rt_1a" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "${local.name}-private-data-rt-1a"
    },
    local.tags,
  )
}

resource "aws_route_table" "private_data_rt_1b" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "${local.name}-private-data-rt-1b"
    },
    local.tags,
  )
}

resource "aws_route_table_association" "private_data_rt_1a" {
  subnet_id      = aws_subnet.private_data_1a.id
  route_table_id = aws_route_table.private_data_rt_1a.id
}

resource "aws_route_table_association" "private_data_rt_1b" {
  subnet_id      = aws_subnet.private_data_1b.id
  route_table_id = aws_route_table.private_data_rt_1b.id
}

resource "aws_subnet" "intra_shared_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.intra_shared_subnet_1a
  availability_zone = local.availability_zone_1a
  tags = merge(
    {
      Name = "${local.name}-intra-shared-1a"
    },
    local.tags,
  )
}

resource "aws_subnet" "intra_shared_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.intra_shared_subnet_1b
  availability_zone = local.availability_zone_1b
  tags = merge(
    {
      Name = "${local.name}-intra-shared-1b"
    },
    local.tags,
  )
}

resource "aws_route_table" "intra_shared_rt_1a" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "${local.name}-intra-shared-rt-1a"
    },
    local.tags,
  )
}

resource "aws_route_table" "intra_shared_rt_1b" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      Name = "${local.name}-intra-shared-rt-1b"
    },
    local.tags,
  )
}

resource "aws_route_table_association" "intra_shared_rt_1a" {
  subnet_id      = aws_subnet.intra_shared_1a.id
  route_table_id = aws_route_table.intra_shared_rt_1a.id
}

resource "aws_route_table_association" "intra_shared_rt_1b" {
  subnet_id      = aws_subnet.intra_shared_1b.id
  route_table_id = aws_route_table.intra_shared_rt_1b.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1b.id,
  ]
}

output "private_app_subnet_ids" {
  value = [
    aws_subnet.private_app_1a.id,
    aws_subnet.private_app_1b.id,
  ]
}

output "private_managed_subnet_ids" {
  value = [
    aws_subnet.private_managed_1a.id,
    aws_subnet.private_managed_1b.id,
  ]
}

output "private_data_subnet_ids" {
  value = [
    aws_subnet.private_data_1a.id,
    aws_subnet.private_data_1b.id,
  ]
}

output "intra_shared_subnet_ids" {
  value = [
    aws_subnet.intra_shared_1a.id,
    aws_subnet.intra_shared_1b.id,
  ]
}

output "public_subnet_cidr_blocks" {
  value = [
    aws_subnet.public_subnet_1a.cidr_block,
    aws_subnet.public_subnet_1b.cidr_block,
  ]
}

output "private_app_subnet_cidr_blocks" {
  value = [
    aws_subnet.private_app_1a.cidr_block,
    aws_subnet.private_app_1b.cidr_block,
  ]
}

output "private_managed_subnet_cidr_blocks" {
  value = [
    aws_subnet.private_managed_1a.cidr_block,
    aws_subnet.private_managed_1b.cidr_block,
  ]
}

output "private_data_subnet_cidr_blocks" {
  value = [
    aws_subnet.private_data_1a.cidr_block,
    aws_subnet.private_data_1b.cidr_block,
  ]
}

output "intra_shared_subnet_cidr_blocks" {
  value = [
    aws_subnet.intra_shared_1a.cidr_block,
    aws_subnet.intra_shared_1b.cidr_block,
  ]
}
