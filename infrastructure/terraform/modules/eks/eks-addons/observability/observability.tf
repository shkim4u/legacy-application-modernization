resource "kubernetes_namespace" "observability" {
  metadata {
    name = "observability"
    labels = {
      purpose = "observability"
      solution = "jaeger-prometheus-opensearch"
    }
  }
}
