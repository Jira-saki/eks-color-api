# --- VPC Outputs ---
# This information is crucial for forwarding to Module EKS  or else

output "vpc_id" {
  description = "The ID of the VPC"
  value = module.aws_vpc.vpc_id # get ID from official modules
}

output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value = module.aws_vpc.private_subnets  # send ID of Private subnets
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value = module.aws_vpc.private_subnets
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value = module.aws_vpc.default_vpc_cidr_block
}