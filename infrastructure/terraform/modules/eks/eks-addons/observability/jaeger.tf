resource "helm_release" "jaeger" {
  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger"
  # version = "3.3.1"
  name = "jaeger"
  namespace = kubernetes_namespace.observability.metadata[0].name

  values = [templatefile("${path.module}/jaeger-values.yaml", {
    certificate_arn = var.certificate_arn
  })]

  timeout = 3600
}
