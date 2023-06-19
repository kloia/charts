# AWS ALB Ingress Helm Chart

Create an Ingress with AWS Load Balancer Controller annotations 
using a JSON schema for the "intended" values and types,
instead of the stringly typed annotations.

Check out the [JSON Schema](values.schema.json)

## Example

These values
```yaml
alb:
  load-balancer-name: hello-there
  tags:
    Project: "Foo"
    Environment: "Dev"
  listen-ports:
    - HTTP: 80
    - HTTPS: 443
  auth-scope:
    - email
    - phone
    - profile
```

will output
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    "alb.ingress.kubernetes.io/auth-scope": "email phone profile"
    "alb.ingress.kubernetes.io/listen-ports": "[{\"HTTP\":80},{\"HTTPS\":443}]"
    "alb.ingress.kubernetes.io/load-balancer-name": "hello-there"
    "alb.ingress.kubernetes.io/tags": "Environment=Dev,Project=Foo"
```



