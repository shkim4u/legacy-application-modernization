resource "helm_release" "prometheus" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart = "prometheus"
  name = "prometheus"
  namespace = "istio-system"
  create_namespace = false

  set {
    name = "ingress.enabled"
    value = true
  }

  set {
    name  = "extraScrapeConfigs"
    value = <<EOF
- job_name: 'hotelspecials-jmx'
  static_configs:
    - targets: ['hotelspecials-service.hotelspecials.svc.cluster.local:9404']
EOF
  }

  timeout = 3600
}
