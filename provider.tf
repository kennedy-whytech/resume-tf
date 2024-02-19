variable "kubeconfig_content" {
  description = "The content of the kubeconfig file"
  type        = string
  sensitive   = true
}

resource "local_file" "kubeconfig" {
  content  = var.kubeconfig_content
  filename = "${path.module}/kubeconfig"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}
