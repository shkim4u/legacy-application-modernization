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

variable "number_of_large_memory_instances" {
  description = "Number of large memory instances for memory intensive workload (e.g. Elasticsearch) testing"
  default = 1
}

variable "large_memory_instance_type" {
  description = "Instance type for large memory instances"
  default = "r7i.8xlarge" # 32vCPU, 256GB RAM
  # Other options: "x2idn.16xlarge"
}

variable "use_amazon_cloudwatch_observability_addon" {
  description = "Use Amazon CloudWatch observability"
  default = false
}
