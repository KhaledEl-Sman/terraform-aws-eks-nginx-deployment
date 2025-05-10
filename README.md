## Documentation for the Terraform AWS EKS Cluster with Nginx Deployment

### Overview
This Terraform configuration provisions an AWS Elastic Kubernetes Service (EKS) cluster along with its supporting VPC infrastructure, and deploys a sample Nginx application on the cluster. The setup includes:

- A VPC with public and private subnets.
- An EKS cluster with two managed node groups.
- Kubernetes provider configured to interact with the EKS cluster.
- Outputs to help configure `kubectl` and update cluster access.
- A Kubernetes deployment and service manifest for Nginx with a LoadBalancer service.

---

### Prerequisites
- AWS CLI configured with the specified profile.
- Terraform installed.
- `kubectl` installed.
- AWS IAM user with necessary permissions (ARN provided via variable).
- Internet access to fetch current IP for cluster endpoint access.

---

### Files and Their Roles
- **providers.tf**: Configures AWS and Kubernetes providers.
- **vpc.tf**: Creates the VPC, subnets, and tags required for EKS.
- **eks-cluster.tf**: Defines the EKS cluster and managed node groups.
- **outputs.tf**: Outputs helpful commands for kubeconfig and cluster access.
- **variables.tf**: Declares variables for region, profile, project name, CIDRs, node types, and IAM principal.
- **terraform.tfvars**: Provides values for variables.
- **nginx-deployment.yaml**: Kubernetes manifest to deploy Nginx with a LoadBalancer service.

---

### Usage Instructions

#### Step 1: Apply Terraform Configuration
Run the following command to provision all AWS resources (VPC, EKS cluster, node groups):

```bash
terraform apply --auto-approve
```

This will create the infrastructure without prompting for confirmation.

#### Step 2: Configure kubectl Access to EKS Cluster
After Terraform finishes, run the two commands from the Terraform outputs to configure your local `kubectl` and update cluster endpoint access:

1. Update kubeconfig to connect to the EKS cluster:

```bash
aws eks update-kubeconfig --region <aws_region> --name <cluster_name> --profile <aws_profile>
```

2. Update the cluster config to enable both public and private endpoint access, allowing your current IP address:

```bash
aws eks update-cluster-config --region <aws_region> --name <cluster_name> --resources-vpc-config endpointPublicAccess=true,endpointPrivateAccess=true,publicAccessCidrs=["$(curl -s https://checkip.amazonaws.com)/32"]
```

> Note: Remove the escape characters (`\`) around the IP address if present.

#### Step 3: Deploy Nginx Application to EKS
Apply the Kubernetes manifest to deploy the Nginx application with a LoadBalancer service:

```bash
kubectl apply -f nginx-deployment.yaml
```

You can verify the LoadBalancer URL by running:

```bash
kubectl get svc nginx-service
```

Access the Nginx app via the external LoadBalancer URL provided.

---

### Cleanup / Destroy Resources

To clean up all resources, follow these steps:

1. Delete the Nginx deployment and service from the cluster:

```bash
kubectl delete -f nginx-deployment.yaml
```

2. Destroy all Terraform-managed AWS resources:

```bash
terraform destroy --auto-approve
```

---

### Variables Summary

| Variable                    | Description                                     |
|-----------------------------|------------------------------------------------|
| `region`                    | AWS region to deploy resources (e.g., eu-west-1) |
| `profile`                   | AWS CLI profile to use                          |
| `project_name`              | Project prefix for naming resources            |
| `vpc_cidr_block`            | CIDR block for the VPC                          |
| `private_subnets_cidr_block`| List of CIDR blocks for private subnets        |
| `public_subnets_cidr_block` | List of CIDR blocks for public subnets         |
| `node_types`                | List of EC2 instance types for node groups     |
| `nodes_desired_capacity`    | Desired number of nodes per node group          |
| `nodes_min_max_capacities`  | Min and max node counts per node group          |
| `principal_arn`             | IAM ARN for cluster admin access                |

---

### Notes

- The EKS cluster is configured with private endpoint access enabled and public endpoint access initially disabled. The update-cluster-config command enables public access restricted to your current IP.
- The Kubernetes provider uses the EKS cluster endpoint and authentication token dynamically fetched from Terraform outputs.
- The Nginx deployment runs 3 replicas exposed via a LoadBalancer service for external access.
- The Terraform AWS EKS module version used is `20.36.0`.
- The VPC module version used is `5.8.1`.
- The cluster Kubernetes version is set to `1.32`.

---

This setup is ideal for learning and testing EKS cluster provisioning and simple app deployment with Terraform, and can be extended for production use with additional security and scaling considerations.
