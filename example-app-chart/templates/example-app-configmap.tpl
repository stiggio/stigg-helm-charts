apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Chart.Name }}-{{ .Release.Revision }}-code
  labels:
    app: {{ .Chart.Name }}
data:
  # this is for test purposes and for real world application a docker image will be used
  app.py: |-
{{ (.Files.Get "appCode.py") | indent 4 }}