resource "helm_release" "jaeger" {
  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger"
  name = "jaeger"
  namespace = kubernetes_namespace.observability.metadata[0].name
}
