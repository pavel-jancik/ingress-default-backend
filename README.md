# ingress-default-backend

A default backend for ingress that redirects instead of returning 404

Base taken from https://github.com/kubernetes/ingress-gce/tree/master/cmd/404-server-with-metrics


Docker images can be obtained at [https://hub.docker.com/r/pjancik/ingress-default-backend](https://hub.docker.com/r/pjancik/ingress-default-backend).

## Running
Use the `-redirect_location` parameter to specify where to redirect all incoming http requests.

```sh
docker build -t ingress-default-backend .
docker run -it --rm -p 8080:8080 ingress-default-backend -redirect_location=https://telma.ai/
```

Example:
```
curl -v http://localhost:8080/
*   Trying 127.0.0.1:8080...
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET / HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 307 Temporary Redirect
< Content-Type: text/html; charset=utf-8
< Location: https://telma.ai/
< Date: Tue, 20 Feb 2024 11:42:19 GMT
< Content-Length: 53
<
<a href="https://telma.ai/">Temporary Redirect</a>.

* Connection #0 to host localhost left intact
```

## Helm configuration
Sample configuration for the [nginx-ingress](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx) helm chart.

```yaml
defaultBackend:
  enabled: true
  image:
    registry: docker.io/pjancik
    image: ingress-default-backend
    tag: "latest"

  extraArgs:
    redirect_location: "https://telma.ai"

  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1

  minReadySeconds: 10

  replicaCount: 3
  minAvailable: 2
  resources:
    limits:
      cpu: 1
      memory: 128Mi
    requests:
      cpu: 10m
      memory: 64Mi

  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50

  serviceAccount:
    automountServiceAccountToken: false
```

## Updating dependencies

```sh
docker run -it --rm --mount type=bind,src=.,target=/project --entrypoint sh docker.io/golang:1.24.5-alpine -c "set -x && cd /project && go get -u && go mod tidy && set +x"

git diff go.mod go.sum
git add go.mod go.sum
git commit -m "Bumping dependencies"
```
