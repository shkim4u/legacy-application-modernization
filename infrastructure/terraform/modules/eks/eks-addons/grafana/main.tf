resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
    labels = {
      purpose = "observability"
    }
  }
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "grafana"
  }

  data = {
    admin-user     = "admin"
    admin-password = var.admin_password
  }

  depends_on = [kubernetes_namespace.grafana]
}

# Grafana dashboard examples:
# - https://grafana.com/grafana/dashboards/13770-1-kubernetes-all-in-one-cluster-monitoring-kr/
resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  name  = "grafana"
  namespace = kubernetes_namespace.grafana.metadata[0].name
  create_namespace = false
  values = [templatefile("${path.module}/values.yaml", {
    admin_existing_secret = kubernetes_secret.grafana.metadata[0].name
    admin_user_key = "admin-user"
    admin_password_key    = "admin-password"
    certificate_arn = var.certificate_arn
  })]

  timeout = 3600
}

resource "helm_release" "tempo" {
  repository = "https://grafana.github.io/helm-charts"
  chart = "tempo"
  name = "tempo"
  namespace = kubernetes_namespace.grafana.metadata[0].name
  create_namespace = false

  # https://github.com/grafana/helm-charts/blob/main/charts/tempo/values.yaml
  set {
    name  = "tempo.metricsGenerator.enabled"
    value = true
  }

  set {
    name  = "tempo.metricsGenerator.remoteWriteUrl"
    value = "http://prometheus-kube-prometheus-prometheus.istio-system:9090/api/v1/write"
  }
}

resource "helm_release" "loki" {
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-distributed"
  name             = "loki-distributed"
  namespace        = kubernetes_namespace.grafana.metadata[0].name
  create_namespace = false
}
