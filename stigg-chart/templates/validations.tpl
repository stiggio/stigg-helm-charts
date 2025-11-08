{{- /* Validation on retrieved values to ensure proper usage of the helm chart */ -}}

{{- if and (eq .Values.persistentCache true) (eq .Values.awsRegion "") }}
  {{ fail "awsRegion must be all set to run persistent cache!" }}
{{- end }}
{{- if and (eq .Values.persistentCache true) (eq .Values.queueUrl "") }}
  {{ fail "queueUrl must be all set to run persistent cache!" }}
{{- end }}
{{- if and (eq .Values.persistentCache true) (eq .Values.redisEnvironmentPrefix "") }}
  {{ fail "redisEnvironmentPrefix must be all set to run persistent cache!" }}
{{- end }}
{{- if and (eq .Values.persistentCache true) (eq .Values.redisHost "") }}
  {{ fail "redisHost must be all set to run persistent cache!" }}
{{- end }}
{{- /* Redis TLS and auth are mandatory when persistent cache is enabled */ -}}
{{- if and (eq .Values.persistentCache true) (ne .Values.redisTls true) }}
  {{ fail "redisTls must be set to true to run persistent cache. Redis is assumed to run with TLS and auth." }}
{{- end }}
{{- if and (eq .Values.persistentCache true) (eq .Values.redisPassword "") }}
  {{ fail "redisPassword must be set to run persistent cache with Redis authentication." }}
{{- end }}
