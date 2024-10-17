resource "helm_release" "jaeger" {
  repository = "https://jaegertracing.github.io/helm-charts"
  chart = "jaeger"
  name = "jaeger"
  namespace = kubernetes_namespace.observability.metadata[0].name

  set {
    name  = "collector.service.otlp.grpc.port"
    value = "4317"
  }

  set {
    name  = "collector.service.otlp.grpc.name"
    value = "otlp-grpc"
  }

  set {
    name  = "collector.service.otlp.http.port"
    value = "4318"
  }

  set {
    name  = "collector.service.otlp.http.name"
    value = "otlp-http"
  }

}
