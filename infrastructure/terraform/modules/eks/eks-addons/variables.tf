variable "region" {}
variable "eks_cluster_name" {}
variable "eks_cluster_endpoint" {}
variable "cluster_certificate_authority_data" {}
variable "oidc_provider" {}
variable "oidc_provider_arn" {}
variable "aws_acm_certificate_arn" {}

variable "route53_account_role_arn" {
  type        = string
  description = "ARN of the IAM role to assume to manage Route53 records."
}

variable "grafana_admin_password" {}

variable "defectdojo_admin_password" {}

variable "additional_iam_policy_arns" {
  type = list(string)
  default = []
}
