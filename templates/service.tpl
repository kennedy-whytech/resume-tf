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