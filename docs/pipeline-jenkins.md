## 1. Objetivo

Este documento describe el proceso de CI/CD implementado en **Jenkins** para una aplicación containerizada que se despliega en **Azure Kubernetes Service (AKS)** utilizando **Azure Container Registry (ACR)** como repositorio de imágenes.

El pipeline cubre:

- Construcción de la imagen Docker.
- Ejecución de tests automatizados.
- Publicación de la imagen en ACR.
- Despliegue de la nueva versión en AKS mediante actualización del Deployment.

---

## 2. Arquitectura general

### Componentes principales

- **Jenkins**: Orquestador del pipeline CI/CD.
- **Repositorio Git**: Contiene el código de la aplicación, el `Jenkinsfile` y los manifiestos de Kubernetes.
- **ACR (Azure Container Registry)**: Almacena las imágenes Docker de la aplicación.
- **AKS (Azure Kubernetes Service)**: Cluster Kubernetes donde corre la aplicación.
- **Service Principal de Azure**: Identidad usada por Jenkins para autenticarse contra Azure.

### Flujo general

1. Un cambio se hace en el repositorio (commit / merge).
2. Jenkins detecta el cambio (webhook o poll SCM).
3. Jenkins ejecuta el pipeline definido en el `Jenkinsfile`.
4. Se construye la imagen Docker y se ejecutan los tests.
5. La imagen se publica en ACR.
6. Jenkins actualiza el Deployment en AKS para usar la nueva imagen.

---

## 3. Prerrequisitos

### 3.1. Recursos en Azure

- **Azure Container Registry (ACR)** creado  
  - Ejemplo: `myacrregistry.azurecr.io`
- **Cluster AKS** creado y configurado
- **Service Principal** con permisos:
  - `AcrPush` sobre el ACR
  - `Contributor` sobre el Resource Group del AKS

### 3.2. Jenkins

- Jenkins instalado (VM, contenedor o servicio gestionado).
- Plugins recomendados:
  - Docker Pipeline
  - Azure CLI (opcional si se usa dentro del agente)
- Jenkins con acceso a:
  - Docker daemon (para build y push de imágenes)
  - Azure CLI (`az` instalado en el agente)

### 3.3. Credenciales en Jenkins

En **Manage Jenkins → Credentials**, se deben configurar:

1. **Service Principal de Azure**  
   - ID: `azure-service-principal`  
   - Tipo: *Username with password*  
   - `Username` = `AZURE_CLIENT_ID`  
   - `Password` = `AZURE_CLIENT_SECRET`

2. **Kubeconfig de AKS**  
   - ID: `aks-kubeconfig`  
   - Tipo: *Secret text*  
   - Valor: contenido del archivo `~/.kube/config` exportado desde AKS.

---

## 4. Estructura del repositorio

Se asume una estructura similar a:

```text
.
├─ Jenkinsfile
├─ Dockerfile
├─ package.json
├─ src/
└─ k8s/
   ├─ deployment.yaml
   ├─ service.yaml
   ├─ configmap.yaml
   └─ secret.yaml
````

* `Jenkinsfile`: define el pipeline declarativo.
* `Dockerfile`: define cómo se construye la imagen de la aplicación.
* `k8s/`: contiene los manifiestos necesarios para desplegar en AKS.

---

## 5. Descripción del Jenkinsfile

El `Jenkinsfile` implementa un pipeline declarativo con las siguientes etapas:

1. **Checkout**
2. **Install Dependencies**
3. **Run Tests**
4. **Build Docker Image**
5. **ACR Login**
6. **Push Image to ACR**
7. **Deploy to AKS**

### 5.1. Variables de entorno

En la sección `environment` del pipeline se definen variables como:

* `ACR_NAME`: nombre del container registry en Azure.
* `ACR_LOGIN_SERVER`: `<ACR_NAME>.azurecr.io`
* `IMAGE_NAME`: nombre lógico de la app, por ejemplo: `optimized-app`.
* `IMAGE_TAG`: etiqueta de la imagen, por ejemplo: `v${BUILD_NUMBER}`.
* `AZURE_CREDENTIALS`: credenciales del service principal (`azure-service-principal`).
* `KUBECONFIG`: credencial con el kubeconfig de AKS (`aks-kubeconfig`).

Estas variables permiten mantener el pipeline parametrizado y fácil de mantener.

---

## 6. Etapas del pipeline

### 6.1. Checkout

Obtiene el código desde el repositorio Git:

* Clona la rama configurada (por ejemplo `main`).
* Garantiza que los archivos necesarios (`Dockerfile`, `k8s/`, etc.) estén disponibles.

### 6.2. Install Dependencies

Instala las dependencias de la aplicación (ejemplo Node.js):

* Ejecuta `npm install`.
* Prepara el entorno para pruebas y build.

### 6.3. Run Tests

Ejecuta los tests automatizados:

* Lanza `npm test` (o el comando de pruebas que use el proyecto).
* Si algún test falla, el pipeline se marca como fallido y se detiene.
* Garantiza que no se despliega código sin pruebas.

### 6.4. Build Docker Image

Construye la imagen con `docker build`:

* Usa el `Dockerfile` del repositorio.
* Etiqueta la imagen como:

  * `${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}`

Ejemplo: `myacrregistry.azurecr.io/optimized-app:v15`

### 6.5. ACR Login

Autentica el agente de Jenkins contra Azure y ACR:

1. Usa `az login` con el Service Principal configurado en Jenkins.
2. Ejecuta `az acr login --name <ACR_NAME>` para registrar el daemon Docker con ACR.

Esto permite hacer `docker push` al registro privado.

### 6.6. Push Image to ACR

Publica la imagen construida:

* Ejecuta `docker push ${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}`.
* Una vez finalizado, la nueva versión queda disponible para consumirse en AKS.

### 6.7. Deploy to AKS

Actualiza el Deployment en el cluster AKS:

1. Crea el archivo `~/.kube/config` en el agente usando el secret de Jenkins.
2. Ejecuta `kubectl` contra el cluster:

   * O bien aplica manifiestos completos:

     ```bash
     kubectl apply -f k8s/
     ```
   * O bien actualiza solo la imagen del Deployment:

     ```bash
     kubectl set image deployment/optimized-app \
       optimized-app=${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG} \
       -n production
     ```

Esta etapa realiza el **rolling update** del Deployment en AKS.

---

## 7. Ejecución del pipeline

### 7.1. Disparador

El pipeline puede ser disparado:

* Manualmente desde la interfaz de Jenkins.
* Automáticamente vía webhooks del repositorio (SCM polling / Git hook).

### 7.2. Observación de resultados

En la vista del job de Jenkins se pueden observar:

* El historial de builds.
* El estado de cada etapa (checkout, tests, build, push, deploy).
* Los logs detallados de cada etapa para troubleshooting.

---

## 8. Verificación del despliegue en AKS

Una vez finalizado el pipeline:

1. Conectarse a AKS:

   ```bash
   az aks get-credentials --resource-group <RG> --name <AKS_NAME>
   ```

2. Ver los pods:

   ```bash
   kubectl get pods -n production
   ```

3. Ver el Deployment:

   ```bash
   kubectl describe deployment optimized-app -n production
   ```

4. Ver el Service (para obtener IP externa o ClusterIP):

   ```bash
   kubectl get svc -n production
   ```

---

## 9. Manejo de errores y posibles mejoras

### 9.1. Errores comunes

* **Fallos en `az login`**

  * Revisar credenciales del Service Principal en Jenkins.
  * Verificar permisos del SP sobre el ACR y el Resource Group.

* **Error al hacer `docker push`**

  * Validar que `ACR_NAME` coincide con el registro de Azure.
  * Confirmar que `az acr login` se ejecutó correctamente.

* **Error de conexión a AKS**

  * Verificar el contenido del kubeconfig guardado en Jenkins.
  * Confirmar red y DNS desde el agente de Jenkins.

### 9.2. Mejoras posibles

* Agregar una etapa de **análisis estático** (linting, SonarQube).
* Implementar **notificaciones** (Slack, email) en la sección `post` del pipeline.
* Incluir **rollback automático** usando `kubectl rollout undo` si el despliegue falla.
* Parametrizar el entorno (`dev`, `staging`, `prod`) mediante parámetros de build.

---

## 10. Conclusión

Este pipeline de Jenkins implementa un flujo CI/CD completo y repetible para una aplicación containerizada en AKS, utilizando ACR como registry.
Asegura que:

* El código pasa por pruebas automatizadas antes del despliegue.
* Cada nueva versión de la imagen se versiona y se almacena en ACR.
* El despliegue a AKS se realiza de forma automatizada y controlada.

