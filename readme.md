# **Optimized App: Node.js, Docker, Kubernetes, SOLID y Notificaciones en Tiempo Real**

Este proyecto es un ejemplo práctico de cómo construir una aplicación **Node.js** optimizada con **Docker** y **Kubernetes**, siguiendo principios **SOLID** e implementando notificaciones en tiempo real usando **Socket.io**. A continuación, te guiaré paso a paso para que puedas entender, ejecutar y modificar el proyecto.

---

## **Tabla de Contenidos**
1. [Requisitos](#requisitos)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Configuración del Proyecto](#configuración-del-proyecto)
4. [Ejecución con Docker](#ejecución-con-docker)
5. [Despliegue en Kubernetes](#despliegue-en-kubernetes)
6. [Integración CI/CD](#integración-cicd)
7. [Manejo Avanzado de Logs](#manejo-avanzado-de-logs)
8. [Arquitecturas de Despliegue](#arquitecturas-de-despliegue)
9. [Automatizaciones Incluidas](#automatizaciones-incluidas)
10. [Pruebas en Tiempo Real](#pruebas-en-tiempo-real)
11. [Mejoras Futuras](#mejoras-futuras)

---

## **Requisitos**

Antes de comenzar, asegúrate de tener instalado lo siguiente:

- **Node.js** (v18 o superior)
- **Docker** (y Docker Compose)
- **Kubernetes** (usamos Minikube para pruebas locales)
- **Git** (opcional, para clonar el repositorio)

---

## **Estructura del Proyecto**

El proyecto está organizado de la siguiente manera:

```
optimized-app/
├── src/                  # Código fuente del backend
│   ├── app.js            # Servidor principal
│   └── services/         # Servicios (ej: notificaciones)
├── public/               # Frontend (HTML, JS)
│   └── index.html        # Página de notificaciones
├── k8s/                  # Archivos de configuración de Kubernetes
│   ├── namespace.yaml    # Namespace para el despliegue
│   ├── configmap.yaml    # Configuración de la aplicación
│   ├── secret.yaml       # Secretos (ACR credentials, etc.)
│   ├── service.yaml      # Servicio Kubernetes
│   └── deployment.yaml   # Despliegue en Kubernetes
├── cicd/                 # Pipelines CI/CD
│   ├── azure-pipelines.yml    # Pipeline Azure DevOps
│   ├── bitbucket-pipelines.yml # Pipeline Bitbucket
│   └── deploy-aws.yml         # Pipeline AWS (alternativo)
├── .github/              # Configuración GitHub Actions
│   └── workflows/
│       └── deploy-aws.yml     # Workflow GitHub Actions para AWS
├── docs/                 # Documentación del proyecto
│   ├── pipeline-jenkins.md    # Documentación Jenkins
│   ├── log-rotation-guide.md  # Guía de rotación de logs
│   ├── bb-branch-guide.md     # Guía de ramas Bitbucket
│   └── deploy-aws.md          # Guía despliegue AWS
├── scripts/              # Scripts de automatización
│   └── log-rotation.sh        # Script de rotación de logs
├── deploy/               # Scripts de despliegue
│   ├── deploy-prod.sh         # Script despliegue producción
│   └── deploy-staging.sh      # Script despliegue staging
├── Dockerfile            # Configuración de Docker
├── docker-compose.yml    # Configuración de Docker Compose
├── package.json          # Dependencias de Node.js
├── Jenkinsfile          # Pipeline declarativo Jenkins
└── README.md             # Este archivo
```

---

## **Configuración del Proyecto**

### **1. Clonar el Repositorio**
Si tienes el proyecto en un repositorio Git, clónalo:
```bash
git clone https://github.com/jaimeirazabal1/optimized-app.git
cd optimized-app
```

### **2. Instalar Dependencias**
Instala las dependencias de Node.js:
```bash
npm install
```

---

## **Ejecución con Docker**

### **1. Construir la Imagen de Docker**
Construye la imagen de Docker:
```bash
docker-compose build
```

### **2. Ejecutar el Contenedor**
Inicia el contenedor:
```bash
docker-compose up
```

### **3. Acceder a la Aplicación**
Abre tu navegador y visita:
```
http://localhost:3000
```

Verás una página con un botón para enviar notificaciones. ¡Haz clic y observa cómo llegan en tiempo real!

---

## **Despliegue en Kubernetes**

### **1. Iniciar Minikube**
Si usas Minikube, inicia un cluster local:
```bash
minikube start
```

### **2. Construir la Imagen en Minikube**
Indica a Minikube que use Docker local:
```bash
eval $(minikube docker-env)
docker-compose build
```

### **3. Aplicar los Manifiestos de Kubernetes**
Despliega la aplicación en Kubernetes con todos los recursos necesarios:
```bash
# Aplicar namespace
kubectl apply -f k8s/namespace.yaml

# Aplicar ConfigMap y Secrets
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

# Aplicar Deployment y Service
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

**Nota:** Los manifiestos avanzados incluyen:
- **3 réplicas** para alta disponibilidad
- **Probes** (readiness / liveness) para health checks
- **Resource limits** configurados
- **ImagePullSecrets** para Azure Container Registry (ACR)
- Configuración desde **ConfigMap** y **Secrets**

### **4. Acceder al Servicio**
Obtén la URL del servicio:
```bash
minikube service nodejs-service
```

Esto abrirá automáticamente la aplicación en tu navegador.

---

## **Integración CI/CD**

Este proyecto incluye pipelines CI/CD completos para múltiples plataformas y entornos cloud.

### **🧩 Jenkins CI/CD para AKS**

Este proyecto incluye un pipeline completo en Jenkins que:

- Construye la imagen Docker
- Ejecuta pruebas automatizadas
- Publica la imagen en Azure Container Registry (ACR)
- Actualiza el Deployment en Azure Kubernetes Service (AKS)

El pipeline declarativo está disponible en el archivo:
- **`Jenkinsfile`**

La documentación completa del pipeline se encuentra en:
- **`docs/pipeline-jenkins.md`**

### **🧩 Azure Pipelines (Build + Push + Deploy AKS)**

Incluimos un pipeline alternativo basado en Azure DevOps para:

- Construcción Docker
- Push a ACR
- Deploy automático a AKS

Este archivo vive en:
- **`cicd/azure-pipelines.yml`**

### **🧩 GitHub Actions para AWS ECS / ECR (Dev → Staging → Prod)**

Para entornos AWS, agregamos un workflow CI/CD que soporta:

- Publicación en Amazon ECR
- Multi-stage: dev, staging, prod
- Rollback automático
- Notificaciones automatizadas

Archivo:
- **`.github/workflows/deploy-aws.yml`**

### **🧩 Bitbucket — Branching Strategy + Pipeline CI/CD**

#### **Guía de ramas**

Se añade un documento que define la estructura estándar de ramas:

- **IC** (Integración continua)
- **PRE** (Preproducción)
- **PRO** (Producción)

Archivo:
- **`docs/bb-branch-guide.md`**

#### **Bitbucket Pipelines (Tests + Coverage + Deploy)**

Incluye:

- Tests paralelos (unit + integration)
- Quality gates (SonarCloud)
- Deploy automático a staging
- Deploy manual a producción

Archivo:
- **`cicd/bitbucket-pipelines.yml`** o **`bitbucket-pipelines.yml`** (raíz)

---

## **Manejo Avanzado de Logs**

El repositorio ahora incluye un sistema de rotación de logs automatizado:

- ✅ Rota logs >100MB
- ✅ Rota logs con antigüedad >7 días
- ✅ Comprime logs rotados
- ✅ Elimina logs >30 días
- ✅ Registra todas las operaciones

**Archivos:**
- **`scripts/log-rotation.sh`** - Script de rotación
- **`docs/log-rotation-guide.md`** - Documentación completa

**Configuración:**
El cron job está configurado para ejecutarse cada 6 horas. Consulta la documentación para configurarlo en tu entorno.

---

## **Arquitecturas de Despliegue**

Este proyecto incluye múltiples pipelines para distintos entornos cloud:

### **Azure AKS**
- **Mediante Jenkins**: Pipeline declarativo con integración completa ACR → AKS
- **Mediante Azure Pipelines**: Alternativa nativa de Azure DevOps

### **AWS ECS/EKS**
- **Mediante GitHub Actions**: Workflow multi-stage (dev → staging → prod)
- Soporte para ECR (Elastic Container Registry)

### **Bitbucket Pipelines**
- **Staging/Prod**: Estrategia de ramas IC–PRE–PRO
- Deploy automático a staging, manual a producción

**Características comunes:**
- ✅ Rolling updates con rollback integrado
- ✅ Health checks y probes configurados
- ✅ Notificaciones de fallos en pipelines
- ✅ Quality gates antes del despliegue

---

## **Automatizaciones Incluidas**

Este proyecto incluye las siguientes automatizaciones:

- ✅ **CI/CD multicloud**: Soporte para Azure, AWS y Bitbucket
- ✅ **Rotación de logs automática**: Script con cron job configurado
- ✅ **Despliegue a Kubernetes**: Manifiestos avanzados con alta disponibilidad
- ✅ **Gestión de repositorios Bitbucket**: Estrategia de ramas IC–PRE–PRO
- ✅ **Notificaciones**: Slack / pipeline failures integradas

---

## **Pruebas en Tiempo Real**

### **1. Enviar Notificaciones**
- Haz clic en el botón **"Enviar Notificación"** en la página web.
- Verás las notificaciones aparecer en tiempo real.

### **2. Probar con Múltiples Clientes**
- Abre la misma URL en varias pestañas o dispositivos.
- Envía una notificación y observa cómo llega a todos los clientes conectados.

---

## **Mejoras Futuras**

Este proyecto es un punto de partida. Aquí tienes algunas ideas para mejorarlo:

1. **Agregar Redis**:
   - Usa Redis para escalar las notificaciones en un entorno distribuido.
   - Ejemplo: `socket.io-redis`.

2. **Autenticación**:
   - Implementa autenticación para identificar usuarios y enviar notificaciones personalizadas.

3. **Frontend Avanzado**:
   - Usa un framework como React o Vue.js para mejorar la interfaz de usuario.

4. **Monitoreo y Observabilidad**:
   - Integra Prometheus y Grafana para métricas.
   - Agrega distributed tracing con Jaeger o Zipkin.
   - Implementa logging centralizado con ELK Stack o Loki.

---

## **Contribuir**

Si deseas contribuir a este proyecto, sigue estos pasos:

1. Haz un **fork** del repositorio.
2. Crea una rama con tu nueva funcionalidad: `git checkout -b nueva-funcionalidad`.
3. Realiza tus cambios y haz commit: `git commit -m "Agrega nueva funcionalidad"`.
4. Envía un **pull request**.

---

## **Licencia**

Este proyecto está bajo la licencia **MIT**. Para más detalles, consulta el archivo [LICENSE](LICENSE).

---

¡Gracias por seguir este tutorial! Si tienes alguna pregunta o sugerencia, no dudes en abrir un issue en el repositorio. 😊

---

