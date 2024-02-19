variable "app_name" {
  description = "Prefix for resource names"
  type        = string
}

variable "replica_count" {
  description = "Number of replicas for the deployment"
  type        = number
}

variable "image" {
  description = "Docker image for the deployment"
  type        = string
}

variable "dns_name" {
  description = "DNS name for the ingress resource"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The k8s namespace in which to deploy the resources"
  type        = string
  default     = "candidate-h"  
}