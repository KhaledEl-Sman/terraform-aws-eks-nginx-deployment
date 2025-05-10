module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name = "${var.project_name}_eks_cluster"
  cluster_version = "1.32"

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    group-1 = {
      instance_types = [var.node_types[0]]
      min_size       = var.nodes_min_max_capacities[0][0]
      max_size       = var.nodes_min_max_capacities[0][1]
      desired_size   = var.nodes_desired_capacity[0]
    },
    group-2 = {
      instance_types = [var.node_types[1]]
      min_size       = var.nodes_min_max_capacities[1][0]
      max_size       = var.nodes_min_max_capacities[1][1]
      desired_size   = var.nodes_desired_capacity[1]
    }
  }

  access_entries = {
    s8r-admin-access = {
      principal_arn = var.principal_arn
      username      = "root-admin"

      policy_associations = {
        admin-access = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    "application" = var.project_name
  }
}
