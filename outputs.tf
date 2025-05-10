output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name} --profile ${var.profile}"
}

output "add_your_endpoint" {
  value = "aws eks update-cluster-config --region ${var.region} --name ${module.eks.cluster_name} --resources-vpc-config endpointPublicAccess=true,endpointPrivateAccess=true,publicAccessCidrs=[\"$(curl -s https://checkip.amazonaws.com)/32\"]"
}
