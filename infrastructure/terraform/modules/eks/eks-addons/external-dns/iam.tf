# Permission policy
resource "aws_iam_policy" "external_dns_role_policy" {
  depends_on  = [var.mod_dependency]
  count       = var.enabled ? 1 : 0
  name        = "${var.cluster_name}-external-dns"
  path        = "/"
  description = "IAM Policy for external DNS controller"

  # policy = file("${path.module}/external_dns_iam_policy.json")
  policy = templatefile("${path.module}/external-dns-iam-policy.json", {
    route53_account_role_arn = var.route53_account_role_arn
  })
}

# Role
data "aws_iam_policy_document" "external_dns_role_trust_policy" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "external_dns_role" {
  count              = var.enabled ? 1 : 0
  name               = "${var.cluster_name}-externa-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_role_trust_policy[0].json
}

resource "aws_iam_role_policy_attachment" "external_dns_role_policy_attachment" {
  count      = var.enabled ? 1 : 0
  role       = aws_iam_role.external_dns_role[0].name
  policy_arn = aws_iam_policy.external_dns_role_policy[0].arn
}
