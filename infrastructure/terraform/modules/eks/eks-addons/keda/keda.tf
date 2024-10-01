resource "helm_release" "keda" {
  repository = "https://kedacore.github.io/charts"
  chart = "keda"
  version = "2.15.1"
  name  = "keda"
  namespace = "keda"
  create_namespace = true

  set {
    name = "prometheus.metricServer.enabled"
    value = true
  }

  set {
    name = "prometheus.metricServer.serviceMonitor.enabled"
    value = true
  }

  set {
    name = "prometheus.operator.enabled"
    value = true
  }

  set {
    name = "prometheus.operator.serviceMonitor.enabled"
    value = true
  }

  timeout = 1200
}
