# Manual de instalación y uso — Log Rotation Script
Script: `log-rotation.sh`  
Funcionalidad: rotación automática de logs por tamaño y antigüedad, compresión y limpieza.  
Periodicidad: cada 6 horas mediante cron.  

---

# 1. Objetivo del Script

El script `log-rotation.sh` automatiza:

- ✔ Rotación de logs mayores a **100MB**
- ✔ Rotación de logs con antigüedad **mayor a 7 días**
- ✔ Compresión GZIP de logs rotados
- ✔ Eliminación de logs **más antiguos de 30 días**
- ✔ Registro detallado de todas las operaciones en `/var/log/log-rotation.log`

Este proceso evita que los logs saturen el almacenamiento del servidor y garantiza una política de retención adecuada.

---

# 2. Requisitos Previos

Antes de instalar:

1. Un servidor Linux (Ubuntu/Debian/CentOS).
2. Shell Bash.
3. Permisos de superusuario (root).
4. Carpeta donde se almacenan los logs de la aplicación (ejemplo `/var/log/myapp`).

---

# 3. Instalación del Script

## 3.1. Crear el directorio del script

```bash
sudo mkdir -p /opt/log-rotation
```

## 3.2. Copiar el script

Coloca el archivo `log-rotation.sh` dentro del directorio:

```bash
sudo cp log-rotation.sh /opt/log-rotation/
```

## 3.3. Dar permisos de ejecución

```bash
sudo chmod +x /opt/log-rotation/log-rotation.sh
```

---

# 4. Preparar los directorios de logs

### 4.1. Crear la carpeta de logs de la aplicación (si no existe)

```bash
sudo mkdir -p /var/log/myapp
```

### 4.2. Crear el archivo de logging del script

```bash
sudo touch /var/log/log-rotation.log
sudo chmod 666 /var/log/log-rotation.log
```

Esto permite que el script registre todas las operaciones.

---

# 5. Contenido del Script

El script analiza logs:

* `*.log` mayores a 100MB → los rota.
* Logs mayores de 7 días → los rota.
* Logs rotados → se comprimen con `.gz`.
* Logs de más de 30 días → se eliminan.
* Todas las acciones → se registran en `/var/log/log-rotation.log`.

---

# 6. Ejecución Manual

Puedes probar su funcionamiento antes de programarlo con cron:

```bash
sudo /opt/log-rotation/log-rotation.sh
```

Verifica resultados con:

```bash
tail -f /var/log/log-rotation.log
```

---

# 7. Configuración del Cron

Para que el script se ejecute automáticamente cada 6 horas:

## 7.1. Editar crontab

```bash
sudo crontab -e
```

## 7.2. Agregar la siguiente línea

```bash
0 */6 * * * /opt/log-rotation/log-rotation.sh
```

Esto ejecuta el script:

* A las 00:00
* A las 06:00
* A las 12:00
* A las 18:00

Si necesitas ejecutarlo cada hora:

```bash
0 * * * * /opt/log-rotation/log-rotation.sh
```

---

# 8. Verificación del Cron

Para revisar si cron está funcionando:

### Ver el log del sistema (Ubuntu/Debian)

```bash
grep CRON /var/log/syslog
```

### Ver estado del servicio cron

```bash
sudo systemctl status cron
```

---

# 9. Buenas Prácticas

* Mantener la ruta `/opt/log-rotation` exclusiva para scripts de administración.
* Monitorizar el archivo `/var/log/log-rotation.log` para verificar actividad.
* Asegurar que la carpeta `/var/log/myapp` no tenga permisos excesivos.
* Mantener el script versionado en un repositorio.

---

# 10. Resumen

Este manual proporciona:

* ✔ Instalación del script
* ✔ Permisos necesarios
* ✔ Configuración del cron
* ✔ Validación de logs
* ✔ Buenas prácticas

Con esto, el sistema de rotación de logs queda completamente automatizado.
