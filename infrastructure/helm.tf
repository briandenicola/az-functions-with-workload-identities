resource "helm_release" "keda" {
  depends_on = [
    azurerm_kubernetes_cluster.this
  ]
  
  name              = "kedacore"
  repository        = "https://kedacore.github.io/charts"
  chart             = "keda"
  namespace         = "keda-system"
  create_namespace  = true

}

