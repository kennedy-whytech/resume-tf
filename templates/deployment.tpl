---
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
          env:
            - name: TITLE
              valueFrom:
                configMapKeyRef:
                  name: webapp-config
                  key: title
          volumeMounts:
            - name: webapp-config
              mountPath: /usr/src/app/views/config.ejs
              subPath: config.ejs
      volumes:
      - name: webapp-config
        configMap:
          name: webapp-config