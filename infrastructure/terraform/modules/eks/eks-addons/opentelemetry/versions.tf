terraform {
  required_version = ">= 1.0"

  required_providers {
    // https://github.com/gavinbunney/terraform-provider-kubectl
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}
