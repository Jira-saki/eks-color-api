# get AZs datya from AWS Region that using
data "aws_availability_zones" "available" {
  state = "available"
}

# Module VPC : Establish a basic network infrastructure.
module "vpc" {
  source = "../../modules/vpc"

# use project_name instead of vpc_name 
  project_name = "eks-color-api"
  environment = "dev"
  cluster_name = "herdened-eks-cluster"

# Dynamically fetch 3 AZs to match Subnets
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)

# CIDR blocks
  vpc_cidr        = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

}

# Modules EKS : build Cluster by use VPC to connect
module "eks" {
    source = "../../modules/eks"
    project_name = "eks-color-api"
    environment = "dev"
    cluster_name = "hardened-eks-cluster"
    cluster_version = "1.31" # latest

    # -- Wiring ---
    # get value from vpc/outputs.tf to put in eks/variables.tf
    vpc_id     = module.vpc.vpc_id
    # Immutable Infrastructure push Nodes to stay in Private Subnets with no ingress (Secure by Design)
    subnet_ids = module.vpc.private_subnets_ids 
    admin_access_cidrs = ["0.0.0.0/0"] 
}