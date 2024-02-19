---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${app_name}-ingress
  namespace: ${namespace}
  annotations:
    external-dns.alpha.kubernetes.io/hostname: ${dns_name}
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:us-east-1:663118211814:certificate/b7966c21-51ec-430e-b6fb-a0410e0af514"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    nginx.ingress.kubernetes.io/rewrite-target:  /
spec:
  ingressClassName: nginx
  rules:
    - host: ${dns_name}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ${app_name}-service
                port:
                  number: 80
