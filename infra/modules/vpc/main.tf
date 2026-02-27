# INFRA MODULE: VPC
# Hardened security

module "aws_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

#Naming
  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

# Networking & Finops:
  enable_nat_gateway = true
  single_nat_gateway = true # for Dev enviroment, budget saving!
  enable_dns_hostnames = true
  enable_dns_support = true

# Tags for Private Subnets (Essential for Internal Load Balancer & Nodes !)
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1" 
  }

tags = {
  Environment = var.environment
  Project    = var.project_name
  ManagedBy  = "Terraform"
}


}