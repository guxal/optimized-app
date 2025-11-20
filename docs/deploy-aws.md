# Deploy to Aws Docs

## ✔ Branch → Ambiente

| Branch    | Stage                 | Ambiente                         |
| --------- | --------------------- | -------------------------------- |
| `dev`     | Build + Deploy        | ambiente de desarrollo (ECS Dev) |
| `staging` | Deploy automatico     | ambiente QA/UAT                  |
| `main`    | Deploy + Confirmación | Producción                       |

---

# 3️⃣ Rollback automático

El job detecta `failure()` y:

1. Obtiene la última versión estable:

```bash
aws ecs describe-services ...
```

2. Restaura la task definition anterior:

```bash
aws ecs update-service --task-definition $PREVIOUS
```

Esto garantiza disponibilidad incluso si el deploy rompe la app.

---

# 4️⃣ Notificaciones

Incluye:

* Slack
* Puedes cambiarlo a Teams, email, GitHub Notifs

Se activa al terminar el deploy:

```yaml
Notify success / failure
```

---

# 5️⃣ Documentación de configuración de Secrets

Crea estos secrets en:

`GitHub → Settings → Secrets → Actions`

| Secret              | Descripción                           |
| ------------------- | ------------------------------------- |
| `AWS_ROLE_ARN`      | Rol OIDC para GitHub (STS AssumeRole) |
| `SLACK_WEBHOOK_URL` | Webhook para notificaciones           |
| `AWS_REGION`        | (Opcional)                            |

### ✔ Política mínima del rol IAM

El rol debe tener políticas:

* `AmazonEC2ContainerRegistryFullAccess`
* `AmazonECSFullAccess`
* `IAMPassRole`
* (opcional) `CloudWatchLogsFullAccess`

---

# 6️⃣ Diagrama de Arquitectura (entregable requerido)

Aquí lo tienes en formato técnico y claro:

```
                ┌───────────────────────────┐
                │        GitHub Repo        │
                └─────────────┬─────────────┘
                              │ push
                              ▼
                  ┌────────────────────┐
                  │  GitHub Actions    │
                  │  Build & Deploy    │
                  └───────┬────────────┘
                          │
          ┌───────────────┼────────────────┬────────────────┐
          ▼               ▼                ▼
   Build Docker      Push to ECR     Update ECS Service
   Image             (Repository)    with new TaskDef
                                          │
                                          ▼
                               ┌──────────────────┐
                               │     ECS Cluster  │
                               │  (Dev/Stg/Prod)  │
                               └───────┬──────────┘
                                       │
                                       ▼
                              New Containers Running
```


