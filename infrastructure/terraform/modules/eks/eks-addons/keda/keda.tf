resource "helm_release" "keda" {
  repository = "https://kedacore.github.io/charts"
  chart = "keda"
  version = "2.15.1"
  name  = "keda"
  namespace = "keda"
  create_namespace = true

  timeout = 1200
}
