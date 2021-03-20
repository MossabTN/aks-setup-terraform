variable "resource_group_name" {
  default     = "maxilog-aks-resources"
  type        = string
  description = "resource group name"
}

variable "resource_group_location" {
  default     = "West Europe"
  type        = string
  description = "resource group location"
}

variable "kubernetes_cluster_name" {
  default     = "maxilog-aks"
  type        = string
  description = "kubernetes cluster name"
}

variable "kubernetes_cluster_version" {
  default     = "1.19.7"
  type        = string
  description = "kubernetes cluster version"
}

variable "kubernetes_cluster_node_count" {
  default     = 1
  type        = number
  description = "kubernetes cluster node count"
}

variable "kubernetes_cluster_vm_size" {
  default     = "Standard_D2_v2"
  type        = string
  description = "kubernetes cluster vm size"
}