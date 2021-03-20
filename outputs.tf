output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_certificate
}