variable "cluster_name" {
  description = "The name of EKS cluster"
}

variable "cluster_version" {
  description = "The version of EKS cluster"
  default = "1.31"
}

variable "region" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}

variable "certificate_authority_arn" {}

# Variable for future use.
variable "create_cluster_addons" {
  default = false
}

# Backward compatible with variable name in "eks_addons" module.
# Will be deleted in the future.
variable "create_karpenter" {default = false}

variable "grafana_admin_password" {}
variable "defectdojo_admin_password" {}

variable "additional_iam_policy_arns" {
  type = list(string)
  default = []
}

variable "number_of_x2idn_16xlarge_instances" {
  description = "Number of x2idn.16xlarge instances used for large instance testing"
  default = 1
}
