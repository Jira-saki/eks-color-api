module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network configuration
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id

  # Security: Enable OIDC เพื่อใช้ IRSA (CKA/CKS Topic)
  enable_irsa = true

  # Authentication & Security
  # In v20, Access Entry will be used instead of modifying 
  # the ConfigMap as before (easier and more reliable).
  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"

  # Endpoint access: For LAB environment, we allow public access
  cluster_endpoint_public_access = true
  cluster_endpoint_public_access_cidrs = var.admin_access_cidrs


  # Immutable Node Groups
  eks_managed_node_groups = {
    hardened_nodes = {
      instance_types = ["t3.medium"]
      capacity_type = "SPOT"  # Finops !!
      max_size     = 3
      min_size     = 1
      desired_size = 2

      # --- Immutable Infrastructure Point ---
      # ใช้ Bottlerocket OS (เน้น Security, Read-only Root FS)
      # no SSH, Root FS is Read-only, updated by changing the node
      ami_type = "BOTTLEROCKET_x86_64"

      # Use SSM to the node without SSH key
      enable_remote_access = false # no SSH !

      tags = {
        Environment = var.environment
        Project = var.project_name
      }
    }
  }
}