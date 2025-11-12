{{- /* Validation on retrieved values to ensure proper usage of the helm chart */ -}}

{{- if and (eq .Values.persistentCache.enabled true) (eq .Values.persistentCache.awsRegion "") }}
  {{ fail "persistentCache.awsRegion must be all set to run persistent cache!" }}
{{- end }}
{{- if and (eq .Values.persistentCache.enabled true) (eq .Values.persistentCache.queueUrl "") }}
  {{ fail "persistentCache.queueUrl must be all set to run persistent cache!" }}
{{- end }}
{{- if and (eq .Values.persistentCache.enabled true) (eq .Values.persistentCache.redis.environmentPrefix "") }}
  {{ fail "persistentCache.redis.environmentPrefix must be all set to run persistent cache!" }}
{{- end }}
{{- if and (eq .Values.persistentCache.enabled true) (eq .Values.persistentCache.redis.host "") }}
  {{ fail "persistentCache.redis.host must be all set to run persistent cache!" }}
{{- end }}