{{- /* A standalone sidecar deployment */ -}}
{{- if eq .Values.sidecar.standalone true }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stigg-sidecar
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stigg-sidecar
  template:
    metadata:
      labels:
        app: stigg-sidecar
    spec:
      containers:
{{- include "stigg.sidecar" . | indent 8 }}
          resources:
            requests:
              cpu: {{ .Values.persistentCache.deploymentResources.cpu.request | quote }}
              memory: {{ .Values.persistentCache.deploymentResources.memory.request | quote }}
            limits:
              cpu: {{ .Values.persistentCache.deploymentResources.cpu.limit | quote }}
              memory: {{ .Values.persistentCache.deploymentResources.memory.limit | quote }}
{{- end }}