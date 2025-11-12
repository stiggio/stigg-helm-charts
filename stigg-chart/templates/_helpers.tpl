{{- /* intenral utilities */ -}}
{{- /* */ -}}
{{- /* */ -}}

{{- define "stigg.redisEnv" }}
{{- $vals := .Values.stiggchart | default .Values }}
- name: REDIS_ENVIRONMENT_PREFIX
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: REDIS_ENVIRONMENT_PREFIX
- name: REDIS_HOST
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: REDIS_HOST
- name: REDIS_PORT
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: REDIS_PORT
- name: REDIS_DB
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: REDIS_DB
- name: REDIS_TLS
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: REDIS_TLS
{{- if $vals.persistentCache.redis.username }}
- name: REDIS_USERNAME
  valueFrom:
    secretKeyRef:
      name: stigg-redis-auth
      key: REDIS_USERNAME
{{- end }}
{{- if $vals.persistentCache.redis.password }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: stigg-redis-auth
      key: REDIS_PASSWORD
{{- end }}
{{- end }}

{{- define "stigg.sqsEnv" }}
- name: AWS_REGION
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: AWS_REGION
- name: QUEUE_URL
  valueFrom:
    configMapKeyRef:
      name: stigg-conf
      key: QUEUE_URL
{{- end }}

{{- /* utilities */ -}}
{{- /* */ -}}
{{- /* */ -}}

{{- /* A utility to bind api keys to env variables from a secret */ -}}
{{- define "stigg.apikeys" }}
{{- /* Fetch the right context to evaluate the values */ -}}
{{- $vals := .Values.stiggchart | default .Values }}
{{- if $vals.apiKeysSecretName }}
# using existing secret
- name: SERVER_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ $vals.apiKeysSecretName }}
      key: stigg_server_api_key
{{- else }}
# using stigg secret
- name: SERVER_API_KEY
  valueFrom:
    secretKeyRef:
      name: stigg-api-keys
      key: SERVER_API_KEY
{{- end }}
{{- end }}

{{- /* A utility to add a stigg sidecar to a given deployment/pod */ -}}
{{- define "stigg.sidecar" }}
- name: stigg-sidecar
  image: public.ecr.aws/stigg/sidecar:{{ .Values.stiggchart.sidecar.imageTag }}
  env:
{{- include "stigg.apikeys" . | indent 4 }}
{{- if and (eq .Values.stiggchart.serverApiKey "") (eq .Values.stiggchart.apiKeysSecretName "") }}
  {{- fail "Either serverApiKey or apiKeysSecretName must be set to run the sidecar!" }}
{{- end }}
{{- if eq .Values.stiggchart.persistentCache.enabled true }}
{{- include "stigg.redisEnv" . | indent 4 }}
{{ end }}
  ports:
  - containerPort: 80
{{- end }}