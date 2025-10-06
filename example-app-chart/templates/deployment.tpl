apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-{{ .Release.Revision }}-code
  labels:
    app: {{ .Chart.Name }}
data:
  app.py: |-
{{ (.Files.Get "appCode.py") | indent 4 }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}
  labels:
    app: app
  annotations:
    revision: {{ .Release.Revision | quote }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      containers:
        - name: python-app
          image: python:3.9-slim
          command:
            - /bin/sh
            - -c
            - |
              pip install --upgrade pip && \
              pip install stigg-sidecar-sdk==3.101.0 pydantic-core==2.16.1 && \
              python -u /app/app.py
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: app-code
              mountPath: /app/app.py
              subPath: app.py
          env:
{{- include "stigg.apikeys" . | indent 12 }}
{{- include "stigg.sidecar" . | indent 8 }}
      volumes:
        - name: app-code
          configMap:
            name: {{ .Chart.Name }}-{{ .Release.Revision }}-code
