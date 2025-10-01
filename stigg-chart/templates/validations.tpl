{{- /* Validation on retrieved values to ensure proper usage of the helm chart */ -}}

{{- if and (eq .Values.persistentCaching true) (eq .Values.awsRegion "") }}
  {{ fail "awsRegion must be all set to run persistent caching!" }}
{{- end }}
{{- if and (eq .Values.persistentCaching true) (eq .Values.queueUrl "") }}
  {{ fail "queueUrl must be all set to run persistent caching!" }}
{{- end }}
{{- if and (eq .Values.persistentCaching true) (eq .Values.redisEnvironmentPrefix "") }}
  {{ fail "redisEnvironmentPrefix must be all set to run persistent caching!" }}
{{- end }}
{{- if and (eq .Values.persistentCaching true) (eq .Values.redisHost "") }}
  {{ fail "redisHost must be all set to run persistent caching!" }}
{{- end }}