resource "kubernetes_namespace" "influxdb" {
  metadata {
    name = "influxdb"
    labels = {
      purpose = "load-testing"
      solution = "infuxdb"
    }
  }
}

resource "helm_release" "influxdb" {
  repository = "https://helm.influxdata.com/"
  chart = "influxdb"
  name = "influxdb"
  namespace = kubernetes_namespace.influxdb.metadata[0].name

  values = [templatefile("${path.module}/influxdb-values.yaml", {
    certificate_arn = var.certificate_arn
  })]

  timeout = 3600
}
