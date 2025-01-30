# **Optimized App: Node.js, Docker, Kubernetes, SOLID y Notificaciones en Tiempo Real**

Este proyecto es un ejemplo práctico de cómo construir una aplicación **Node.js** optimizada con **Docker** y **Kubernetes**, siguiendo principios **SOLID** e implementando notificaciones en tiempo real usando **Socket.io**. A continuación, te guiaré paso a paso para que puedas entender, ejecutar y modificar el proyecto.

---

## **Tabla de Contenidos**
1. [Requisitos](#requisitos)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Configuración del Proyecto](#configuración-del-proyecto)
4. [Ejecución con Docker](#ejecución-con-docker)
5. [Despliegue en Kubernetes](#despliegue-en-kubernetes)
6. [Pruebas en Tiempo Real](#pruebas-en-tiempo-real)
7. [Mejoras Futuras](#mejoras-futuras)

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
│   └── deployment.yaml   # Despliegue en Kubernetes
├── Dockerfile            # Configuración de Docker
├── docker-compose.yml    # Configuración de Docker Compose
├── package.json          # Dependencias de Node.js
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

### **3. Aplicar el Deployment**
Despliega la aplicación en Kubernetes:
```bash
kubectl apply -f k8s/deployment.yaml
```

### **4. Acceder al Servicio**
Obtén la URL del servicio:
```bash
minikube service nodejs-service
```

Esto abrirá automáticamente la aplicación en tu navegador.

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

4. **CI/CD**:
   - Configura un pipeline de CI/CD con GitHub Actions o GitLab CI para automatizar despliegues.

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

