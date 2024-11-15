variable "domain_name" {
  # default = "www.mydemo.co.kr"
  default = "*.mydemo.co.kr"
}

variable "domain_name_staging" {
  # default = "www-stg.mydemo.co.kr"
  default = "*.stg.mydemo.co.kr"
}

variable "subject_alternative_names" {
  default = ["*.stg.mydemo.co.kr"]
}

# variable "subject_alternative_names" {
#   default = ["cool-stg.mydemo.co.kr", "test-stg.mydemo.co.kr"]
# }

variable "certificate_authority_arn" {}
variable "eks_cluster_name" {}
