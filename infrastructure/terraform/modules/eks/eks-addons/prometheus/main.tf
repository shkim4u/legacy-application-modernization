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

  # Grafana is configured in separate module.
  set {
    name = "grafana.enabled"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
    value = <<EOF
- job_name: 'hotelspecials-jmx'
  static_configs:
    - targets: ['hotelspecials-service.hotelspecials.svc.cluster.local:9404']
- job_name: 'karpenter'
  static_configs:
    - targets: ['karpenter.karpenter.svc.cluster.local:8080']
EOF
  }

  timeout = 3600
}
