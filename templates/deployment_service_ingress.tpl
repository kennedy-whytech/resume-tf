apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${app_name}-deployment
  namespace: ${namespace}
spec:
  replicas: ${replica_count}
  selector:
    matchLabels:
      app: ${app_name}-app
  template:
    metadata:
      labels:
        app: ${app_name}-app
    spec:
      containers:
        - name: ${app_name}-container
          image: ${image}
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ${app_name}-service
  namespace: ${namespace}
spec:
  selector:
    app: ${app_name}-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${app_name}-ingress
  namespace: ${namespace}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:us-east-1:663118211814:certificate/b7966c21-51ec-430e-b6fb-a0410e0af514"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
spec:
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
  tls:
    - hosts:
        - ${dns_name}
      secretName: ${app_name}-tls
