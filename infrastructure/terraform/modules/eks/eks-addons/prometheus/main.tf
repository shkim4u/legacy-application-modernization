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

  # Grafana is configured in separate module.
  set {
    name = "grafana.enabled"
    value = false
  }

#   set {
#     name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
#     value = <<EOF
# - job_name: 'hotelspecials-jmx'
#   static_configs:
#     - targets: ['hotelspecials-service.hotelspecials.svc.cluster.local:9404']
# - job_name: 'karpenter'
#   static_configs:
#     - targets: ['karpenter.karpenter.svc.cluster.local:8080']
# EOF
#   }
  set {
    name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
    value = <<EOF
- job_name: 'hotelspecials-jmx'
  static_configs:
    - targets: ['hotelspecials-service.hotelspecials.svc.cluster.local:9404']
- job_name: 'karpenter'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - karpenter
  relabel_configs:
  - source_labels:
    - __meta_kubernetes_endpoints_name
    - __meta_kubernetes_endpoint_port_name
    action: keep
    regex: karpenter;http-metrics
EOF
  }

  timeout = 3600
}
