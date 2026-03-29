# music-assistant-alexa-skill

A Helm chart for deploying the [Music Assistant Alexa Skill prototype](https://github.com/alams154/music-assistant-alexa-skill-prototype) on Kubernetes.

This chart deploys a Flask-based Alexa Skill backend that bridges Amazon Alexa voice requests to a [Music Assistant](https://music-assistant.io/) server. The application exposes an HTTPS endpoint that Alexa calls, handles authentication via basic auth credentials, and includes an ASK CLI (Alexa Skills Kit CLI) setup interface.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- A publicly reachable HTTPS hostname for the Alexa skill endpoint (required by Amazon)

## Installing the Chart

Add the chart and install with a release name:

```bash
helm install my-release ./music-assistant-alexa-skill \
  --set config.skillHostname=my-skill.example.com \
  --set credentials.appUsername=admin \
  --set credentials.appPassword=changeme
```

> **Note:** `config.skillHostname` is required. Without it the Alexa skill cannot register its endpoint.

## Uninstalling the Chart

```bash
helm uninstall my-release
```

## Configuration

### Core

| Parameter | Description | Default |
|---|---|---|
| `replicaCount` | Number of pod replicas | `1` |

### Image

| Parameter | Description | Default |
|---|---|---|
| `image.repository` | Container image repository | `ghcr.io/alams154/music-assistant-alexa-skill-prototype` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag (defaults to chart `appVersion`) | `""` |
| `imagePullSecrets` | List of image pull secret names | `[]` |

### Name Overrides

| Parameter | Description | Default |
|---|---|---|
| `nameOverride` | Override the chart name component of resource names | `""` |
| `fullnameOverride` | Override the full release name used in resource names | `""` |

### Service Account

| Parameter | Description | Default |
|---|---|---|
| `serviceAccount.create` | Create a Kubernetes ServiceAccount | `true` |
| `serviceAccount.annotations` | Annotations to add to the ServiceAccount | `{}` |
| `serviceAccount.name` | ServiceAccount name; defaults to release fullname | `""` |

### Pod

| Parameter | Description | Default |
|---|---|---|
| `podAnnotations` | Annotations to add to the pod template | `{}` |
| `podLabels` | Extra labels to add to the pod template | `{}` |
| `podSecurityContext` | Pod-level security context | `{}` |
| `securityContext` | Container-level security context | `{}` |

### Service

| Parameter | Description | Default |
|---|---|---|
| `service.type` | Kubernetes Service type | `ClusterIP` |
| `service.port` | Service port; must match `config.port` | `5000` |

### Ingress

| Parameter | Description | Default |
|---|---|---|
| `ingress.enabled` | Create an Ingress resource | `false` |
| `ingress.className` | `ingressClassName` for the Ingress | `""` |
| `ingress.annotations` | Annotations for the Ingress | `{}` |
| `ingress.hosts[0].host` | Hostname for the ingress rule | `alexa-skill.example.com` |
| `ingress.hosts[0].paths[0].path` | Path for the ingress rule | `/` |
| `ingress.hosts[0].paths[0].pathType` | Path type | `Prefix` |
| `ingress.tls` | TLS configuration (list of `secretName` + `hosts`) | `[]` |

### Resources

| Parameter | Description | Default |
|---|---|---|
| `resources` | CPU/memory resource requests and limits | `{}` |

### Health Probes

| Parameter | Description | Default |
|---|---|---|
| `livenessProbe.httpGet.path` | HTTP path for liveness check | `/status` |
| `livenessProbe.httpGet.port` | Named port for liveness check | `http` |
| `livenessProbe.initialDelaySeconds` | Delay before first liveness probe | `15` |
| `livenessProbe.periodSeconds` | Liveness probe interval | `30` |
| `readinessProbe.httpGet.path` | HTTP path for readiness check | `/status` |
| `readinessProbe.httpGet.port` | Named port for readiness check | `http` |
| `readinessProbe.initialDelaySeconds` | Delay before first readiness probe | `10` |
| `readinessProbe.periodSeconds` | Readiness probe interval | `10` |

Both probes target the `/status` endpoint, which must be reachable without authentication.

### Persistence

ASK CLI stores its credentials at `/root/.ask` inside the container. Enabling persistence ensures credentials survive pod restarts, which is important for the `/setup` workflow.

| Parameter | Description | Default |
|---|---|---|
| `persistence.enabled` | Mount a PersistentVolume for ASK CLI credentials | `false` |
| `persistence.storageClass` | StorageClass for the PVC | `""` |
| `persistence.accessMode` | PVC access mode | `ReadWriteOnce` |
| `persistence.size` | PVC storage request | `100Mi` |
| `persistence.existingClaim` | Name of an existing PVC to use | `""` |

### Autoscaling

| Parameter | Description | Default |
|---|---|---|
| `autoscaling.enabled` | Create a HorizontalPodAutoscaler | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `1` |
| `autoscaling.maxReplicas` | Maximum replicas | `3` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization to trigger scaling | `80` |

When autoscaling is enabled, `replicaCount` is ignored and replica control is delegated to the HPA.

### Scheduling

| Parameter | Description | Default |
|---|---|---|
| `nodeSelector` | Node selector labels | `{}` |
| `tolerations` | Toleration list | `[]` |
| `affinity` | Affinity/anti-affinity rules | `{}` |

### Application Configuration

These non-sensitive values are rendered into a ConfigMap and injected into the container via `envFrom`.

| Parameter | Description | Default |
|---|---|---|
| `existingConfigMap` | Name of an existing ConfigMap to use (skips creation) | `""` |
| `config.skillHostname` | **(Required)** Public HTTPS hostname for the Alexa skill endpoint | `""` |
| `config.maHostname` | Music Assistant server hostname | `""` |
| `config.port` | Port the Flask application listens on | `"5000"` |
| `config.debugPort` | Debugger port; set to `"0"` to disable | `"0"` |
| `config.locale` | Skill locale | `"en-US"` |
| `config.awsDefaultRegion` | AWS region used by ASK CLI | `"us-east-1"` |
| `config.tz` | Container timezone (IANA tz name) | `"UTC"` |
| `config.quietHttp` | Set to `"1"` to suppress verbose HTTP logs | `"1"` |

### Credentials

Sensitive credentials are stored in a Kubernetes Secret and injected as individual environment variables.

| Parameter | Description | Default |
|---|---|---|
| `existingSecret` | Name of an existing Secret to use (must have `APP_USERNAME` and `APP_PASSWORD` keys) | `""` |
| `credentials.appUsername` | Username for basic authentication | `""` |
| `credentials.appPassword` | Password for basic authentication | `""` |

## Using Existing Resources

This chart supports a bring-your-own pattern for Secrets, ConfigMaps, and PVCs, making it compatible with GitOps tools such as Sealed Secrets, External Secrets Operator, and Vault Agent.

**Existing Secret:**
```bash
helm install my-release ./music-assistant-alexa-skill \
  --set existingSecret=my-skill-secret \
  --set config.skillHostname=my-skill.example.com
```

**Existing ConfigMap:**
```bash
helm install my-release ./music-assistant-alexa-skill \
  --set existingConfigMap=my-skill-config
```

**Existing PVC:**
```bash
helm install my-release ./music-assistant-alexa-skill \
  --set persistence.enabled=true \
  --set persistence.existingClaim=my-ask-pvc \
  --set config.skillHostname=my-skill.example.com
```

## Ingress with TLS Example

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: my-skill.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: my-skill-tls
      hosts:
        - my-skill.example.com

config:
  skillHostname: my-skill.example.com
```

## Post-Install Setup

After installing the chart, visit `<app-url>/setup` to configure the Alexa skill using the ASK CLI interface.

Check application health at `<app-url>/status`.

To access the app locally when using the default `ClusterIP` service type:

```bash
kubectl port-forward svc/my-release-music-assistant-alexa-skill 5000:5000
```

Then open `http://localhost:5000/setup` in your browser.

## Chart Information

| Field | Value |
|---|---|
| Chart version | `0.1.0` |
| App version | `latest` |
| Helm version | Helm 3 (API v2) |
| Home | https://github.com/alams154/music-assistant-alexa-skill-prototype |
