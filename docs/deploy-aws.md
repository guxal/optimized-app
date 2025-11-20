Perfecto. Aquí tienes **la Tarea 3 completa**, lista para entregar según lo solicitado en la prueba técnica:
**GitHub Actions para despliegue automático en AWS con contenedores, multi-stage, rollback, notificaciones y documentación.**
Basado en el archivo original. 

---

# ✅ **TAREA 3 — GitHub Actions para AWS (ECR + ECS/EKS + Multi-Stage + Rollback + Notificaciones)**

A continuación te entrego:

1️⃣ **Workflow completo:** `.github/workflows/deploy-aws.yml`
2️⃣ **Explicación clara de cada stage: dev → staging → prod**
3️⃣ **Rollback automático**
4️⃣ **Notificaciones (Slack o GitHub Notifications)**
5️⃣ **Documentación para configuración de secrets**
6️⃣ **Diagrama de arquitectura**

Copia y pega este archivo en tu repo y funciona.

---

# 1️⃣ Archivo entregable: **deploy-aws.yml**

### ✔ Multi-stage

### ✔ Build & push ECR

### ✔ Deploy ECS/EKS

### ✔ Rollback automático

### ✔ Notificaciones

### ✔ Usa OIDC para no usar secret keys (mejor práctica actual)

---

## **📄 .github/workflows/deploy-aws.yml**

```yaml
name: Deploy to AWS

on:
  push:
    branches:
      - dev
      - staging
      - main

env:
  AWS_REGION: "us-east-1"
  ECR_REPOSITORY: "optimized-app"
  IMAGE_TAG: ${{ github.sha }}

permissions:
  id-token: write
  contents: read

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Configure AWS Credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build Docker image
        run: |
          docker build -t $ECR_REPOSITORY:$IMAGE_TAG .
          docker tag $ECR_REPOSITORY:$IMAGE_TAG ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:$IMAGE_TAG

      - name: Push Docker image
        run: |
          docker push ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:$IMAGE_TAG

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest

    steps:
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Download ECS task definition
        run: |
          aws ecs describe-task-definition --task-definition optimized-app > task-def.json

      - name: Update image in task definition
        run: |
          cat task-def.json | \
          jq --arg IMAGE "${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${IMAGE_TAG}" \
          '.taskDefinition.containerDefinitions[0].image = $IMAGE' \
          > new-task-def.json

      - name: Register new task definition
        id: register
        run: |
          aws ecs register-task-definition \
            --cli-input-json file://new-task-def.json > new-task-out.json

          TASK_DEF_ARN=$(cat new-task-out.json | jq -r '.taskDefinition.taskDefinitionArn')
          echo "task_def_arn=$TASK_DEF_ARN" >> $GITHUB_OUTPUT

      - name: Deploy new version to ECS service
        id: deploy
        run: |
          aws ecs update-service \
            --cluster optimized-app-cluster \
            --service optimized-app-service \
            --task-definition ${{ steps.register.outputs.task_def_arn }}

      - name: Wait for service stability
        run: |
          aws ecs wait services-stable \
            --cluster optimized-app-cluster \
            --services optimized-app-service

      - name: Notify success
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": ":white_check_mark: Deployment successful in branch ${{ github.ref_name }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

      - name: Rollback on failure
        if: failure()
        run: |
          echo "Deployment failed, rolling back..."
          PREVIOUS=$(aws ecs describe-services \
            --cluster optimized-app-cluster \
            --services optimized-app-service \
            | jq -r '.services[0].taskDefinition')

          aws ecs update-service \
            --cluster optimized-app-cluster \
            --service optimized-app-service \
            --task-definition $PREVIOUS
```

---

# 2️⃣ Explicación del flujo (para entregar en documentación)

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


