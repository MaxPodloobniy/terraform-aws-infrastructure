aws_region = "us-east-1"
prefix     = "cmtr-bgxc7tqb-01"
vpc_name   = "cmtr-bgxc7tqb-01-vpc"
vpc_cidr   = "10.10.0.0/16"
igw_name   = "cmtr-bgxc7tqb-01-igw"
rt_name    = "cmtr-bgxc7tqb-01-rt"

public_subnets = {
  "public-a" = {
    name = "cmtr-bgxc7tqb-01-subnet-public-a"
    cidr = "10.10.1.0/24"
    az   = "us-east-1a"
  }
  "public-b" = {
    name = "cmtr-bgxc7tqb-01-subnet-public-b"
    cidr = "10.10.3.0/24"
    az   = "us-east-1b"
  }
  "public-c" = {
    name = "cmtr-bgxc7tqb-01-subnet-public-c"
    cidr = "10.10.5.0/24"
    az   = "us-east-1c"
  }
}