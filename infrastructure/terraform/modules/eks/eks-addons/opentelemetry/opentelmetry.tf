resource "kubernetes_namespace" "opentelemetry" {
  metadata {
    name = "opentelemetry"
    labels = {
      purpose = "observability"
      solution = "opentelemetry"
    }
  }
}

resource "helm_release" "opentelemetry_operator" {
  repository  = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart = "opentelemetry-operator"
  name = "opentelemetry-operator"
  namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  create_namespace = false
  values = [templatefile("${path.module}/opentelemetry-operator-values.yaml", {
  })]

  timeout = 3600
}

resource "kubectl_manifest" "opentelemetry_resources" {
  for_each  = data.kubectl_path_documents.opentelemetry_manifests.manifests
  yaml_body = each.value
  depends_on = [helm_release.opentelemetry_operator]
}

resource "helm_release" "opentelemetry_demo" {
  repository  = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart = "opentelemetry-demo"
  name = "opentelemetry-demo"
  namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  create_namespace = false
  values = [templatefile("${path.module}/opentelemetry-demo-values.yaml", {
    certificate_arn = var.certificate_arn
  })]

  timeout = 3600
}
