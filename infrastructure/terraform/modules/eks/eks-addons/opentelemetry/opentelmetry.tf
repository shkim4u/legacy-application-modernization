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

resource "kubectl_manifest" "opentelemetry_collector" {
  # yaml_body = file("${path.module}/collector-manifests/opentelemetry-collector.yaml")
  yaml_body = values(data.kubectl_path_documents.opentelemetry_collector_manifests.manifests)[0]
  # override_namespace = kubernetes_namespace.opentelemetry.metadata[0].name
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
