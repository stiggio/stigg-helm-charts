{{- /* A required deployment for running in 'persistent-caching' mode */ -}}
{{- if eq .Values.persistentCaching true }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stigg-persistent-cache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stigg-persistent-cache
  template:
    metadata:
      labels:
        app: stigg-persistent-cache
    spec:
      containers:
        - name: persistent-cache-service
          image: public.ecr.aws/stigg/persistent-cache-service:{{ .Values.persistentCacheImageTag }}
          env:
{{- include "stigg.redisEnv" . | indent 12 }}
{{- include "stigg.apikeys" . | indent 12 }}
{{- include "stigg.sqsEnv" . | indent 12 }}
          ports:
            - containerPort: 8080
{{- end }}