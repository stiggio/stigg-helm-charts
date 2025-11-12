{{- /* HPA for persistent-cache-service, enabled automatically when persistentCache is enabled */ -}}
{{- if eq .Values.persistentCache.enabled true }}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" -}}
apiVersion: autoscaling/v2
{{- else -}}
apiVersion: autoscaling/v2beta2
{{- end }}
kind: HorizontalPodAutoscaler
metadata:
  name: stigg-persistent-cache
  labels:
    app: stigg-persistent-cache
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/instance: {{ .Release.Name }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: stigg-persistent-cache
  minReplicas: {{ .Values.persistentCache.deploymentHPA.minReplicas }}
  maxReplicas: {{ .Values.persistentCache.deploymentHPA.maxReplicas }}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.persistentCache.deploymentHPA.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.persistentCache.deploymentHPA.targetMemoryUtilizationPercentage }}
{{- end }}
