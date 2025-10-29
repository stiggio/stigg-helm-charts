# stigg-helm-charts

Kubernetes is a powerful open-source platform for automating deployment, scaling, and management of containerized applications. It provides a consistent way to run workloads across environments, whether on-premises or in the cloud. Interacting with Kubernetes is done using tools like kubectl (the command-line interface for managing clusters and resources) and Helm (a package manager that simplifies deploying and managing complex applications). This repository contains resources for deploying Stigg components, alongside a simple example app on Kubernetes, making it easier to get started and integrate Stigg in your deployments. Learn more on at [Helm documentation](https://helm.sh/docs/).

## Stigg components
- [Stigg Sidecar documentation](https://docs.stigg.io/docs/sidecar)
- [Stigg Persistent Caching documentation](https://docs.stigg.io/docs/persistent-caching)

Stigg provides two main components for feature management and entitlement checks in your applications:

### Stigg Sidecar
The Stigg Sidecar is a lightweight service that runs alongside your application (as a separate container in the same pod or as a standalone service). It acts as a proxy between your app and the Stigg backend, handling:
- Entitlement checks (does a customer have access to a feature?)
- Feature flag evaluation
- Usage metering and reporting
- Caching of entitlement data for performance

Your application communicates with the sidecar over HTTP or gRPC using a simple SDK or direct API calls. The sidecar manages authentication, API key rotation, and communication with Stigg’s cloud service, so your app code remains simple and secure.

### Stigg Persistent Cache
The Persistent Cache is an optional component that stores entitlement and feature data locally in Redis. This provides:
- Faster entitlement checks (low latency)
- Resilience to network outages or Stigg backend downtime
- Reduced load on the Stigg backend

The sidecar will first check the persistent cache for entitlement data before reaching out to the Stigg backend, ensuring high availability and performance.

> **⚠️ Important:** Enabling a Persistent Cache requires additional setup from Stigg.

### Example: Entitlement Check Flow
Suppose your app needs to check if a customer can access a premium feature:

1. **Your app** sends a request to the Stigg Sidecar (e.g., via the Stigg SDK).
2. **The sidecar** receives the request and checks the persistent cache (Redis) for entitlement data.
3. If not found or expired, the sidecar queries the Stigg backend and updates the cache.
4. The sidecar returns the entitlement result to your app.

This architecture decouples your app from direct communication with the Stigg backend, improves reliability, and simplifies security management. 

## Setup

> **⚠️ Important:** You must configure the sidecar and persistent cache using the provided Helm chart values (see `values.yaml`).

### Dependencies
- [kubectl](https://kubernetes.io/docs/tasks/tools/): Command-line tool for interacting with Kubernetes clusters.
- [minikube](https://minikube.sigs.k8s.io/docs/): Tool for running Kubernetes locally. Use for local development/testing.
- [helm](https://helm.sh/docs/intro/install/): Package manager for Kubernetes. Use for installing and managing charts.

Use `kubectl` to interact with your cluster, `minikube` for local clusters, and `helm` to install/manage charts.

## Running example app

This example assumes you are running a local Kubernetes cluster using [minikube](https://minikube.sigs.k8s.io/docs/) or [kind](https://kind.sigs.k8s.io/), but you can also use any managed Kubernetes service (e.g., GKE, EKS, AKS) if you prefer.

When you deploy the example app with the Stigg charts, the following resources will be created in your cluster:
- **example-app**: A pod running your sample application (e.g., Python HTTP server).
- **stigg-sidecar**: A sidecar container running alongside the app, handling entitlement checks and feature flags
- **stigg-persistent-cache**: A deployment running the persistent cache service
- **Redis**: A pod running Redis, used by the persistent cache for fast local storage
- **Kubernetes Services**: For exposing the app and Redis within the cluster
- **Secrets and ConfigMaps**: For securely passing API keys and configuration to the app and sidecar

> **⚠️ Note:** to simplify this repo, the app code is injected dynamically using a configmap. The best practice is to build and deploy apps with container images.

The setup will look like this:

```
+-------------------+         +-------------------+
|                   |  HTTP   |                   |
|   Your App Pod    +-------->+   Stigg Sidecar   |
|                   |         |                   |
+-------------------+         +-------------------+
                                       |
                                       v
                              +-------------------+
                              |   Redis Pod       |
                              +-------------------+
                                       ∧
                                       |
                              +-------------------+
                              | Stigg Persistent  |
                              | Cache Deployment  |
                              +-------------------+
                                       ∧
                                       |
                              +-------------------+
                              |  Stigg Cloud API  |
                              +-------------------+
```

After deployment, you should see pods for your app, the sidecar, the persistent cache, and Redis running in your cluster. You can inspect these resources using `kubectl get pods` and `kubectl get services`.

## Using Helm

This section provides a step-by-step tutorial for deploying the example app with Stigg charts:

1. **Update the example app values:**
   Edit the `example-app-chart/values.yaml` file to set your Stigg API keys, Redis host, and any other configuration values required for your environment. The `awsRegion` and `queueUrl` fields are used to configure the persistent cache to retrieve updates via AWS SQS. 

   By default, the example app will deploy a Redis instance in your cluster for use by the persistent cache. If you already have a Redis deployment or want to use an external Redis service, you can disable the built-in Redis by removing the redis template file `example-app-chart/templates/redis.yaml` and then set `redisHost` to point to your external Redis instance.

   If you do not want to use persistent caching, you can disable it by setting `persistentCaching: false` in the values file.

   First, we'll create a namespace to provision resources:
   ```sh
   export NAMESPACE=helm
   kubectl create ns ${NAMESPACE}
   ```

2. **Copy the stigg-chart to be a sub-chart of the example app:**
   ```sh
   cp -r stigg-chart example-app-chart/charts
   ```

3. **Deploy the app and dependencies:**
   Use Helm to install the example app chart (which now includes the stigg sub-chart):
   ```sh
   helm install -n ${NAMESPACE} example-app ./example-app-chart
   ```

4. **Inspect the app deployment:**
   ```sh
   kubectl describe -n ${NAMESPACE} pod $(kubectl get pods -n ${NAMESPACE} -l app=app -o jsonpath='{.items[0].metadata.name}')
   kubectl logs -n ${NAMESPACE} $(kubectl get pods -n ${NAMESPACE} -l app=app -o jsonpath='{.items[0].metadata.name}')
   ```

5. **Port-forward app to a local port:**
   ```sh
   kubectl port-forward -n ${NAMESPACE} $(kubectl get pods -l app=app -n ${NAMESPACE} -o jsonpath='{.items[0].metadata.name}') 9090
   ```

6. **Send a request:**
   ```sh
   curl "localhost:9090?customer_id=<CUSTOMER-ID>>&feature_id=<FEATURE-ID>"
   ```

7. **Inspect the redis content:**
   ```sh
   kubectl run -it redis-client -n ${NAMESPACE} --rm --image=redis:7.2.4 --restart=Never -- redis-cli -h redis -p 6379 KEYS '*'
   ```

8. **Uninstall all resources:**
   To remove all resources created by the example app and its dependencies, run:
   ```sh
   helm uninstall -n ${NAMESPACE} example-app
   kubectl delete ns ${NAMESPACE}
   ```

### Production usage

To use the Helm chart in production:
- Review and customize the `values.yaml` file to fit your environment (e.g., API keys, image tags, resource limits).
- Update your Charts to utilize `stigg-chart` as a sub-chart of your app, or alternatively deploy the Stigg as a standalone chart. Either way, additional changes might be necessary to fit your specific deployment setup. 
- Monitor your deployments and use Kubernetes best practices for scaling, security, and reliability.
- Refer to [Helm best practices](https://helm.sh/docs/chart_best_practices/) for production deployments.

> **⚠️ Important:** It is highly recommend to test the integration in a staging environment before rolling out to production.

## Using Kubectl

If you do not want to use Helm directly, you can render the Kubernetes manifests using `helm template` and `kubectl kustomize` commands and apply them with `kubectl`.
1. First, edit the values in `./stigg-chart/values.yaml` to match your setup (api key, persistent caching, etc.). 
2. Generate the Stigg components manifests:
    ```sh
    helm template stigg ./stigg-chart > kustomize/generated/stigg-manifests.yaml
    ```
    Manifests should include an api-keys secret. If persistent caching is enabled, a delpoyment resource will be added as well.
3. Use the `kubectl` cli to add a stigg side-car to your app deployment and ensure your app has access to Stigg api-keys:
    ```sh
    kubectl kustomize kustomize > kustomize/generated/app-manifests.yaml
    ```
    Inspect the generated `kustomize/app-manifests.yaml`. It should contain a configmap alongside a deployment with 2 containers, having environment varaibles mounted from the api-keys secret.
4. Create a new namespace and provision the resources using `kubectl`:
    ```sh
    export NAMESPACE="no-helm"

    kubectl create ns ${NAMESPACE}

    # provision stigg resources
    kubectl apply -n ${NAMESPACE} -f kustomize/generated/stigg-manifests.yaml

    # create a redis if running with persistent-caching
    kubectl apply -n ${NAMESPACE} -f kustomize/redis.yaml
    
    # provision the app
    kubectl apply -n ${NAMESPACE} -f kustomize/generated/app-manifests.yaml    
    ```
5. Port-forward to the created pod and send a request:
    ```sh
    kubectl port-forward -n ${NAMESPACE} $(kubectl get pods -l app=app -n ${NAMESPACE} -o jsonpath='{.items[0].metadata.name}') 9090

    curl "localhost:9090?customer_id=<CUSTOMER-ID>>&feature_id=<FEATURE-ID>"
    ```
6. Clean resources (after closing all connections to pods):
    ```sh
    kubectl delete ns ${NAMESPACE}
    ```

## Troubleshooting

- Check pod and deployment status:
  ```sh
  kubectl get -n ${NAMESPACE} pods
  kubectl describe pod -n ${NAMESPACE} <pod-name>
  kubectl logs -n ${NAMESPACE} <pod-name>
  ```
- Ensure all required secrets and config maps are created. You can check for their existence with:
  ```sh
  kubectl get -n ${NAMESPACE} secret,configmap
  ```
  Look for entries like `stigg-api-keys` (secret) and any config maps referenced in your deployment. If any are missing, check your Helm values and templates, and reinstall the chart:
  ```sh
  helm upgrade -n ${NAMESPACE} --install example-app ./example-app-chart
  ```
- Verify that your API keys and configuration values are correct in `values.yaml`.
- For Helm-specific issues, run:
  ```sh
  helm status -n ${NAMESPACE} <release-name>
  helm get all -n ${NAMESPACE} <release-name>
  ```
- Consult the [Helm troubleshooting guide](https://helm.sh/docs/faq/#troubleshooting) and [Kubernetes troubleshooting docs](https://kubernetes.io/docs/tasks/debug/).
- If you see an error when sending HTTP requests to the example app:
   - Make sure the port-forward command from step 4 is still running in a separate terminal window.
   - Check that the example app pod is running and ready:
     ```sh
     kubectl get pods -n ${NAMESPACE} -l app=app
     kubectl describe pod -n ${NAMESPACE} $(kubectl get pods -n ${NAMESPACE} -l app=app -o jsonpath='{.items[0].metadata.name}')
     ```
   - If the pod is not ready, check the logs for errors:
     ```sh
     kubectl logs -n ${NAMESPACE} $(kubectl get pods -n ${NAMESPACE} -l app=app -o jsonpath='{.items[0].metadata.name}')
     ```
   - Ensure nothing else is using port 9090 on your machine.
- If you encounter issues with leftover resources or failed installs, you can remove the Helm release and ensure all resources are deleted before retrying:
  ```sh
  helm uninstall example-app
  kubectl get all -l app=app
  kubectl delete all -l app=app
  # Also check for any remaining secrets or configmaps:
  kubectl get secret,configmap -l app=app
  kubectl delete secret,configmap -l app=app
  # Then retry the installation:
  helm install example-app ./example-app-chart
  ```