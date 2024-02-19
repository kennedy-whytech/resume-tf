resource "kubernetes_manifest" "deployment" {
  manifest = yamldecode(templatefile("${path.module}/templates/deployment.tpl", {
    app_name   = var.app_name
    replica_count = var.replica_count
    image         = var.image
    namespace     = var.namespace
  }))
}
resource "kubernetes_manifest" "service" {
  manifest = yamldecode(templatefile("${path.module}/templates/service.tpl", {
    app_name   = var.app_name
    namespace     = var.namespace
  }))
}
resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(templatefile("${path.module}/templates/ingress.tpl", {
    app_name   = var.app_name
    dns_name      = var.dns_name
    namespace     = var.namespace
  }))
}

resource "kubernetes_config_map" "webapp_config" {
  metadata {
    name = "webapp-config"
    namespace     = var.namespace
  }

  data = {
    "config.ejs" = <<-EOT
      <!DOCTYPE html>
      <html>
      <head>
          <title>Config</title>
      </head>
      <body>
          <h1>This is mounted to ConfigMap</h1>
          <a href="/">Go Home</a>
      </body>
      </html>
    EOT
    "title" = "Kennedy's Production Test" 
  }
}