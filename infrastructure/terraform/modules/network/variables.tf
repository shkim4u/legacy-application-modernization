variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type = list(string)
  default = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type = string
  default = "10.21.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets of VPC"
  type = list(string)
  default = ["10.21.0.0/18", "10.21.128.0/18"]
}

variable "private_subnets" {
  description = "Private subnets of VPC"
  type = list(string)
  default = ["10.21.64.0/18", "10.21.192.0/18"]
}

# variable "dms_tgw_name" {
#   description = "The name of the Transit Gateway for migrating data from on-premises to AWS"
#   type = string
#   default = "DMS-TGW"
# }

variable "dms_tgw_route" {
  description = "The CIDR block for the route to the Transit Gateway"
  type = string
  default = "10.0.0.0/11"
}
