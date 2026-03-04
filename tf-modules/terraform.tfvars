aws_region    = "us-east-1"
prefix        = "cmtr-bgxc7tqb"
vpc_cidr      = "10.10.0.0/16"
instance_type = "t3.micro"
ami_id        = "ami-0f3caa1cf4417e51b"

public_subnets = {
  "public-a" = {
    name = "cmtr-bgxc7tqb-subnet-public-a"
    cidr = "10.10.1.0/24"
    az   = "us-east-1a"
  }
  "public-b" = {
    name = "cmtr-bgxc7tqb-subnet-public-b"
    cidr = "10.10.3.0/24"
    az   = "us-east-1b"
  }
  "public-c" = {
    name = "cmtr-bgxc7tqb-subnet-public-c"
    cidr = "10.10.5.0/24"
    az   = "us-east-1c"
  }
}

allowed_ip_range = ["18.153.146.156/32", "89.22.198.22/32"]