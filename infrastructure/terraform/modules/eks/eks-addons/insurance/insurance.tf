resource "kubernetes_namespace" "insurance" {
  metadata {
    name = local.namespace
    labels = {
      name = local.name
      app = local.app
      purpose = "insurance"
      istio-injection = "enabled"
    }
  }
}

resource "aws_iam_policy" "insurance_irsa" {
  name = "Insurance-IRSA-Policy-${var.eks_cluster_name}"
  path = "/"
  policy = file("${path.module}/insurance-irsa-policy.json")
  description = "IAM policy for Insurance IRSA"
}

module "insurance_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "Insurance-IRSA-Role-${var.eks_cluster_name}"

  role_policy_arns = {
    policy = aws_iam_policy.insurance_irsa.arn
  }

  oidc_providers = {
    main = {
      provider_arn = var.irsa_oidc_provider_arn
      namespace_service_accounts = ["${kubernetes_namespace.insurance.metadata[0].name}:${var.service_account_name}"]
    }
  }

  tags = {
    Description = "IAM role for Insurance"
  }
}

resource "kubernetes_service_account" "insurance_irsa" {
  metadata {
    name = var.service_account_name
    namespace = kubernetes_namespace.insurance.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.insurance_irsa.iam_role_arn
    }
  }

  timeouts {
    create = "30m"
  }
}
