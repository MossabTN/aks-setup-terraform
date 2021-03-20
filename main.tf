terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.0.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.3"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].host

    client_key             = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].host

  client_key             = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_config[0].cluster_ca_certificate)
}

resource azurerm_resource_group aks-group {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource azurerm_kubernetes_cluster aks-cluster {
  name                = var.kubernetes_cluster_name
  location            = azurerm_resource_group.aks-group.location
  resource_group_name = azurerm_resource_group.aks-group.name
  dns_prefix          = var.kubernetes_cluster_name
  kubernetes_version = var.kubernetes_cluster_version

  default_node_pool {
    name                 = "default"
    orchestrator_version = var.kubernetes_cluster_version
    node_count           = var.kubernetes_cluster_node_count
    vm_size              = var.kubernetes_cluster_vm_size
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "Standard"
    network_plugin    = "kubenet"
  }

  tags = {
    Environment = "Production"
  }
}

resource helm_release nginx_ingress {
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
  name       = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
}

resource helm_release cert-manager {
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
  name       = "cert-manager"
  namespace = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"

  set {
    name = "installCRDs"
    value = true
  }
}
