# Variable definitions for VPC module
variable "project_name" {
  type    = string
  description = "Project name for naming resources"
}

variable "environment" {
  type    = string
  description = "Environment name (e.g., dev, prod)"
}

# Networking Variables (Essential for VPC configuration)
variable "vpc_cidr" {
  type    = string
  description = "the CIDR block for the VPC"
  default = "10.0.0.0/16"

  # Add validation for Security Nest practise
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "azs" {
  type    = list(string)
  description = "Availability zones for the subnets"
}

variable "public_subnets" {
  type    = list(string)
  description = "List of public subnet CIDR blocks"
}

# --- Private subnets for Node Groups and internal resources
variable "private_subnets" {
  type    = list(string)
  description = "List of private subnet CIDR blocks" 
}

# EKS Specific Variables (for tagging and integration)
variable "cluster_name" {
  type = string
  description = "The name of the EKS cluster for resource tagging"
}
