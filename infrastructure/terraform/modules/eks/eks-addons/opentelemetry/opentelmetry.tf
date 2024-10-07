resource "kubernetes_namespace" "opentelemetry" {
  metadata {
    name = "opentelemetry"
    labels = {
      purpose = "observability"
      solution = "opentelemetry"
    }
  }
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
