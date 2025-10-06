{{- /* intenral utilities */ -}}
{{- /* */ -}}
{{- /* */ -}}

{{- define "stigg.redisEnv" }}
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
- name: SERVER_API_KEY
  valueFrom:
    secretKeyRef:
      name: stigg-api-keys
      key: SERVER_API_KEY
- name: CLIENT_API_KEY
  valueFrom:
    secretKeyRef:
      name: stigg-api-keys
      key: CLIENT_API_KEY
{{- end }}

{{- /* A utility to add a stigg sidecar to a given deployment/pod */ -}}
{{- define "stigg.sidecar" }}
- name: stigg-sidecar
  image: public.ecr.aws/stigg/sidecar:{{ .Values.stiggchart.sidecarImageTag }}
  env:
{{- include "stigg.apikeys" . | indent 4 }}
{{- if eq .Values.stiggchart.serverApiKey "" }}
  {{- fail "serverApiKey must be set to run the sidecar!" }}
{{ end }}
{{- if eq .Values.stiggchart.persistentCaching true }}
{{- include "stigg.redisEnv" . | indent 4 }}
{{ end }}
  ports:
  - containerPort: 80
{{- end }}