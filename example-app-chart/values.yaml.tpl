stiggchart:
  serverApiKey: "${STIGG_SERVER_API_KEY}"
  sidecar:
    imageTag: "latest"
    standalone: false
  persistentCache: 
    enabled: true
    redis:
      environmentPrefix: "production"
      host: "redis"
      port: "6379"
      db: "0"
      username: "default"
      password: "${REDIS_PASSWORD}"
      tls: true
    awsRegion: "us-east-2"
    queueUrl: "${STIGG_SQS_QUEUE_URL}"
  extraDeploy:
    - apiVersion: v1
      kind: ConfigMap
      metadata:
        name: example-extra-configmap
        labels:
          app: example-app
      data:
        test-key: "test-value"