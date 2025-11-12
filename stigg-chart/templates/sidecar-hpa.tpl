{{- /* HPA for stigg-sidecar, enabled automatically when sidecar.standalone is enabled */ -}}
{{- if eq .Values.sidecar.standalone true }}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
apiVersion: autoscaling/v2
{{- else -}}
apiVersion: autoscaling/v2beta2
{{- end }}
kind: HorizontalPodAutoscaler
metadata:
  name: stigg-sidecar
  labels:
    app: stigg-sidecar
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: {{ .Release.Name }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: stigg-sidecar
  minReplicas: {{ .Values.sidecar.deploymentHPA.minReplicas }}
  maxReplicas: {{ .Values.sidecar.deploymentHPA.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.sidecar.deploymentHPA.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.sidecar.deploymentHPA.targetMemoryUtilizationPercentage }}
{{- end }}
