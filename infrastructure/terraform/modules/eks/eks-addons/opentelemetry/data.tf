data "kubectl_path_documents" "opentelemetry_manifests" {
  pattern = "${path.module}/manifests/*.yaml"
  vars = {
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
}
