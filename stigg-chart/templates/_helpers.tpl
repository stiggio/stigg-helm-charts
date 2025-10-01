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

{{- /* An intenral utility */ -}}
{{- define "stigg.redisEnv" }}
- name: REDIS_ENVIRONMENT_PREFIX
  value: {{ .Values.redisEnvironmentPrefix | quote }}
- name: REDIS_HOST 
  value: {{ .Values.redisHost | quote }}
{{- end }}

{{- /* A utility to add a stigg sidecar to a given deployment/pod */ -}}
{{- define "stigg.sidecar" }}
- name: stigg-sidecar
  image: public.ecr.aws/stigg/sidecar:{{ .Values.stiggchart.sidecarImageTag }}
  env:
{{ include "stigg.apikeys" . | indent 4 }}

{{ if eq .Values.serverApiKey "" }}
  {{ fail "serverApiKey must be set to run the sidecar!" }}
{{ end }}

{{ if eq .Values.persistentCaching true }}
{{ include "stigg.redisEnv" . | indent 4 }}
{{ end }}

  ports:
  - containerPort: 80
{{- end }}

{{- /* An intenral utility */ -}}
{{- define "stigg.sqsEnv" }}
- name: AWS_REGION
  value: {{ .Values.awsRegion | quote }}
- name: QUEUE_URL
  value: {{ .Values.queueUrl | quote }}
{{- end }}