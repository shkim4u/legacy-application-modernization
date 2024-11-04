resource "null_resource" "depends_upon" {
  triggers = {
    depends_on = join("", var.depends_upon)
  }
}

resource "helm_release" "external_dns" {
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart     = "external-dns"
  version = "1.15.0"
  name      = "external-dns"
  namespace = "kube-system"
  create_namespace = true

  set {
    name  = "image.pullPolicy"
    value = "Always"
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "policy"
    value = "upsert-only"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns_role[0].arn
  }

  # set {
  #   name  = "extraArgs.aws-assume-role"
  #   value = var.route53_account_role_arn
  # }

  values = [
    yamlencode({
      extraArgs = [
        "--aws-assume-role=${var.route53_account_role_arn}"
      ]
    })
  ]

  depends_on = [var.mod_dependency]

  timeout   = 1800

  wait = true
  wait_for_jobs = true
}
