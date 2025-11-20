# Explicación del pipeline

## ✔ IC — Integración Continua

* Corre tests en paralelo
* Corre calidad del código
* NO hay despliegue

## ✔ PRE — Preproducción

* Corre todo lo de IC
* Despliega automáticamente a staging

## ✔ PRO — Producción

* Corre todo
* Deploy manual (safe)
* Garantiza calidad antes de release

---

# Paralelización

Bitbucket corre ambos steps simultáneamente:

```yaml
parallel:
  - step: *unit-tests
  - step: *integration-tests
```

Esto:

* Acelera ejecución
* Aísla fallos
* Permite pipelines más rápidos

---

# Coverage + Carpeta generada

Se espera que los tests generen:

```
coverage/
 ├─ lcov.info
 ├─ index.html
 └─ summary.json
```

Se guardan como artifacts para revisar.

---

# Quality Gates (SonarCloud)

Incluye:

* Análisis completo del código
* Detección de duplicados
* Vulnerabilidades
* Maintainability issues
* Coverage requerido (>80%)

Para integrarlo:

### Crear estos secretos en Bitbucket:

| Variable            | Descripción         |
| ------------------- | ------------------- |
| `SONAR_TOKEN`       | Token de SonarCloud |
| `SONAR_PROJECT_KEY` | Key del proyecto    |
| `SONAR_ORG`         | Organización        |

---

# Despliegue condicional

El deploy solo corre si:

✔ Tests pasan
✔ Quality Gate pasa
❌ Si Sonar falla → NO despliega
❌ Si tests fallan → NO despliega

Esto ya está garantizado por el orden del pipeline:

```yaml
- step: *sonar-scan
- step: *deploy-staging   # Only runs if sonar passes
```

---

# Script de despliegue

### **deploy/deploy-staging.sh**

```bash
#!/bin/bash
set -e

echo "Deploying to AWS ECS Staging..."
aws ecs update-service \
  --cluster optimized-app-staging \
  --service optimized-app-service \
  --force-new-deployment
```

### **deploy/deploy-prod.sh**

```bash
#!/bin/bash
set -e

echo "Deploying to AWS ECS Production..."
aws ecs update-service \
  --cluster optimized-app-prod \
  --service optimized-app-service \
  --force-new-deployment
```

