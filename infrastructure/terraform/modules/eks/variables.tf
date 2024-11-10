variable "cluster_name" {
  description = "The name of EKS cluster"
}

variable "cluster_version" {
  description = "The version of EKS cluster"
  default = "1.30"
}

variable "region" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}

variable "certificate_authority_arn" {}

variable "route53_account_role_arn" {
  type        = string
  description = "ARN of the IAM role to assume to manage Route53 records."
}

# Variable for future use.
variable "create_cluster_addons" {
  default = false
}

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
