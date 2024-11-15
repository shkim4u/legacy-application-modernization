variable "certificate_arn" {}

variable "jaeger_storage_type" {
  description = "Storage type for Jaeger. Valid values are elasticsearch, cassandra, and memory."
  default     = "cassandra"
}
