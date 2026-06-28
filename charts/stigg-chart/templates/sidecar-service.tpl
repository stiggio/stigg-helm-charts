{{- /* A service for the standalone sidecar deployment */ -}}
{{- if eq .Values.sidecar.standalone true }}
apiVersion: v1
kind: Service
metadata:
  name: stigg-sidecar
spec:
  selector:
    app: stigg-sidecar
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
{{- end }}