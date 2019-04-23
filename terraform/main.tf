provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

// Create a VPC
resource "aws_vpc" "dz_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "dz_vpc"
  }
}

// Create public subnets
resource "aws_subnet" "public_subnets" {
  count             = "${length(var.vpc_public_subnet_ips)}"
  vpc_id            = "${aws_vpc.dz_vpc.id}"
  cidr_block        = "${element(var.vpc_public_subnet_ips, count.index)}"
  availability_zone = "${element(var.vpc_subnet_azs, count.index)}"

  tags {
    Name                           = "${element(var.vpc_public_subnet_names, count.index)}"
    "kubernetes.io/cluster/dz-fyp" = "shared"
  }
}

// Create private subnets
resource "aws_subnet" "private_subnets" {
  count             = "${length(var.vpc_private_subnet_ips)}"
  vpc_id            = "${aws_vpc.dz_vpc.id}"
  cidr_block        = "${element(var.vpc_private_subnet_ips, count.index)}"
  availability_zone = "${element(var.vpc_subnet_azs, count.index)}"

  tags {
    Name                              = "${element(var.vpc_private_subnet_names, count.index)}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/dz-fyp"    = "shared"
  }
}

// Create an internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.dz_vpc.id}"

  tags {
    Name = "dz_igw"
  }
}

// Define our standard routing table
resource "aws_route_table" "public_r" {
  vpc_id = "${aws_vpc.dz_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "dz_public_route_table"
  }
}

// Routing table association for public subnets
resource "aws_route_table_association" "public_a" {
  count          = "${length(var.vpc_public_subnet_ips)}"
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_r.id}"
}

// Create a nat gateway
resource "aws_nat_gateway" "ng" {
  count         = 1
  allocation_id = "${var.allocation_id}"
  subnet_id     = "${aws_subnet.public_subnets.*.id[count.index]}"

  tags {
    Name = "dz_ng"
  }

  depends_on = ["aws_internet_gateway.gw"]
}

// Define private routing table
resource "aws_route_table" "private_r" {
  vpc_id = "${aws_vpc.dz_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ng.id}"
  }

  tags {
    Name = "dz_private_route_table"
  }
}

// Routing table association for public subnets
resource "aws_route_table_association" "private_a" {
  count          = "${length(var.vpc_private_subnet_ips)}"
  subnet_id      = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_r.id}"
}

module "dz-fyp" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = "dz-fyp"
  subnets      = ["${concat(aws_subnet.private_subnets.*.id, aws_subnet.public_subnets.*.id)}"]
  vpc_id       = "${aws_vpc.dz_vpc.id}"

  worker_groups = [
    {
      instance_type        = "t2.medium"
      ami_id               = "${var.worker_ami_id}"
      asg_desired_capacity = "4"
      asg_max_size         = "5"
      asg_min_size         = "3"
      root_volume_size     = "20"
      key_name             = "dimitra_witcloud"
      subnets              = "${join(",", aws_subnet.private_subnets.*.id)}"
    },
  ]

  tags = {
    environment = "test"
  }
}
