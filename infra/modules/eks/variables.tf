variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "cluster_name" {
  type = string
  description = "Name of the EKS cluster"
}

# -- Network Wiring ---
variable "vpc_id" {
  type = string
  description = "VPC ID where EKS cluster will be deployed"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of private subnet IDs for EKS worker nodes"
}

# --- Hardening & Security ---
variable "admin_access_cidrs" {
  type = list(string)
  description = "List of CIDR blocks allowed to access EKS API endpoint"
  #  recommended to specify real IP address in the .tfvars file.
  default = [ "0.0.0.0/0" ]
}

# --- Project Context & Tags ----
variable "environment" {
  type = string
  description = "Environment tag for resources (e.g., dev, staging, prod)"
}

variable "project_name" {
  type = string
  description = "Project name tag for resources"
}