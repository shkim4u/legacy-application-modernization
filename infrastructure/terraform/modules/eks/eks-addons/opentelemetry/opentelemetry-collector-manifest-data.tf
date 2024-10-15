data "kubectl_path_documents" "opentelemetry_collector_manifests" {
  pattern = "${path.module}/collector-manifests/*.yaml"
  vars = {
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
}
