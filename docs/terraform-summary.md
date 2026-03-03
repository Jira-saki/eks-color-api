# EKS Terraform Project Summary

## Project Overview
This project is an AWS EKS (Elastic Kubernetes Service) deployment managed via Terraform. The repository is structured with separate modules for networking (`vpc`) and Kubernetes orchestration (`eks`), along with environment-specific configurations under `infra/environments`. The goal is to establish reproducible and scalable infrastructure for the `eks-color-api` application.

### Phase 2: Immutable Infrastructure
Phase 2 focuses on implementing immutable infrastructure. Instead of modifying existing resources, new versions of infrastructure components are provisioned and deployed. This approach reduces configuration drift, simplifies rollbacks, and ensures consistency across environments.

---

## Terraform Layout
```
infra/                    # environment-specific settings
  environments/
    dev/
      main.tf            # reference to modules and variable values
      provider.tf
modules/
  vpc/                    # networking definitions (VPC, subnets, etc.)
  eks/                    # EKS cluster and node group logic
```

---

## VPC Module Snippet
```hcl
# modules/vpc/main.tf
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags = { Name = "${var.name}-vpc" }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  cidr_block        = var.private_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.this.id
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "${var.name}-private-${count.index + 1}" }
}
```

The VPC module defines the virtual private cloud, public/private subnets, NAT gateways, and associated routing. The environment config passes CIDR ranges and AZ lists.

---

## EKS Module Snippet
```hcl
# modules/eks/main.tf
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [var.cluster_security_group_id]
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]
}

resource "aws_eks_node_group" "managed" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = var.node_role_arn

  subnet_ids = var.subnet_ids
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_groups = [var.node_security_group_id]
  }
}
```

This module creates the EKS cluster and a managed node group. Parameters are exposed for names, roles, subnet lists, and scaling.

---

## Security Handling
- Security groups are created and referenced across modules to ensure proper ingress/egress.
- IAM roles and policies are defined in the environment or a central security module and attached to the cluster and node group.
- SSH access to nodes is restricted via `remote_access` settings on the node group and by locking down the source security group CIDRs.

---

## Node Refresh Logic
To support immutable infrastructure, node refresh or replacement is implemented via Terraform managed configurations:
- Changing the `ami_type` or `launch_template` for the node group forces a recreation of nodes.
- Using AWS EKS managed node group update strategies (e.g., `max_unavailable`) ensures rolling replacement.
- The `terraform taint` command or updates in the module variables trigger node recreation, allowing a clean, immutable upgrade path.

The logic is typically orchestrated in CI/CD pipelines to apply new configurations and then verify cluster stability before removing old instances.

---

## Summary
This project leverages Terraform modules to abstract networking and Kubernetes infrastructure. Phase 2's immutable infrastructure goal is achieved through strict resource replacement patterns and clear versioning. Security and node refresh strategies ensure a hardened, maintainable EKS deployment that supports scalable application workloads.

*End of journal entry.*
