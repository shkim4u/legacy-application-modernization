resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "kube-prometheus-stack"
  name = "prometheus"
  namespace = "istio-system"
  create_namespace = false

  # set {
  #   name = "ingress.enabled"
  #   value = true
  # }

  # Resources.
  set {
    name = "prometheus.prometheusSpec.resources.requests.cpu"
    value = "500m"
  }

  set {
    name = "prometheus.prometheusSpec.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name = "prometheus.prometheusSpec.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name = "prometheus.prometheusSpec.resources.limits.memory"
    value = "1Gi"
  }

  set {
    name = "prometheus.prometheusSpec.enableRemoteWriteReceiver"
    value = true
  }

  # Grafana is configured in separate module.
  set {
    name = "grafana.enabled"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
    value = file("${path.module}/prometheus-additional-scrape-configs.yaml")
  }

  set {
    name  = "prometheus.prometheusSpec.logLevel"
    value = "debug"
  }

  # From Otel demo.
  # --storage.tsdb.retention.time=15d
  # --config.file=/etc/config/prometheus.yml
  # --storage.tsdb.path=/data
  # --web.console.libraries=/etc/prometheus/console_libraries
  # --web.console.templates=/etc/prometheus/consoles
  # --enable-feature=exemplar-storage
  # --enable-feature=otlp-write-receiver

  # set {
  #   name = "prometheus.prometheusSpec.additionalArgs[0]"
  #   value = "--enable-feature=otlp-write-receiver"
  # }

  # set {
  #   name = "prometheus.prometheusSpec.additionalArgs[1]"
  #   value = "--enable-feature=exemplar-storage"
  # }

  # set {
  #   name = "prometheus.prometheusSpec.additionalArgs[2]"
  #   value = "--storage.tsdb.retention.time=15d"
  # }

  values = [
    file("${path.module}/prometheus-additional-args.yaml")
  ]

  timeout = 3600
}
