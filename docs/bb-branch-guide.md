# ✅ **bb-branch-guide.md**

**Guía de estructuración de ramas IC, PRE y PRO para Bitbucket**

---

# **Objetivo**

Documentar el proceso para crear nuevas ramas **IC**, **PRE** y **PRO** en un **repositorio A**, manteniendo una estructura consistente con la rama **DEV** del **repositorio B**, sin afectar el histórico ni generar divergencias innecesarias.
Además, definir buenas prácticas para integrarlo con **Bitbucket Pipelines**.

---

# **1. Principios generales del versionamiento**

### ✔ Mantener el histórico limpio

Nunca sobrescribir commits existentes en `main`, `PRO`, `PRE`, `IC` o `DEV`.
Evitar `push --force` en ramas compartidas.

### ✔ Mantener simetría entre repositorios

La rama `DEV` del repositorio B es la referencia original.
Las ramas del repositorio A deben basarse directamente en esta rama para asegurar homogeneidad.

### ✔ Mantener flujo simple

Cada rama tiene un propósito:

| Rama    | Propósito                                |
| ------- | ---------------------------------------- |
| **IC**  | Integración continua. Desarrollo activo. |
| **PRE** | Preproducción. Testing, QA, UAT.         |
| **PRO** | Producción. Código estable.              |

---

# **2. Flujo para crear nuevas ramas**

> **IMPORTANTE:** Nunca crear estas ramas desde `main` o desde ramas viejas.
> Siempre deben crearse desde la rama equivalente a `DEV`.

### **2.1. Obtener la última versión del repositorio A**

```bash
git fetch --all
git checkout DEV
git pull origin DEV
```

### **2.2. Crear la rama IC**

```bash
git checkout -b IC origin/DEV
git push -u origin IC
```

### **2.3. Crear la rama PRE**

```bash
git checkout -b PRE origin/DEV
git push -u origin PRE
```

### **2.4. Crear la rama PRO**

```bash
git checkout -b PRO origin/DEV
git push -u origin PRO
```

> Crear las ramas directamente desde `origin/DEV` asegura que ambas estructuras estén alineadas con repositorio B.

---

# **3. Consideraciones importantes para no afectar histórico**

### **3.1. Nunca usar `git push --force` en ramas IC, PRE o PRO**

Si es necesario corregir commits, usar revert:

```bash
git revert <commit_id>
```

### **3.2. Mantener sincronización con DEV**

Si se actualiza `DEV` en repositorio B (o en repositorio A):

```bash
git checkout IC
git merge origin/DEV
git push
```

> **Nunca hacer rebase** sobre ramas compartidas.

### **3.3. Mantener ramas protegidas**

Configurar en Bitbucket → Repository settings → Branch permissions:

* PRO → solo merge vía Pull Request
* PRE → solo merge de IC
* IC → abiertos para desarrollo
* Forzar PR + Code Review + Pipelines status OK

---

# **4. Política de Pull Requests**

## 🔹 Flujo recomendado:

1. Los desarrolladores trabajan en feature branches:
   `feature/JIRA-123-new-login`
2. Se hace PR → IC
3. IC corre tests automáticos
4. Si está aprobado, se hace PR → PRE
5. QA valida en PRE
6. Con aprobación manual, se hace PR → PRO

---

# **5. Integración con Bitbucket Pipelines**

### **5.1. pipelines para cada rama**

En `bitbucket-pipelines.yml` se recomienda:

```yaml
pipelines:
  branches:
    IC:
      - step:
          name: "Build & Test"
          script:
            - npm install
            - npm run test
    PRE:
      - step:
          name: "Staging Deployment"
          script:
            - ./deploy-staging.sh
    PRO:
      - step:
          name: "Production Deployment"
          trigger: manual
          script:
            - ./deploy-prod.sh
```

### **5.2. Reglas clave**

* PRE y PRO deben requerir el estatus de pipeline “passed” antes del merge.
* PRO debe tener confirmación manual.
* Se puede incluir integración con SonarCloud, Slack o Jira.

---

# **6. Mantenimiento del repositorio**

### ✔ Actualizar IC frecuentemente desde DEV

Para evitar divergencias:

```bash
git checkout IC
git pull origin DEV
git push
```

### ✔ Actualizar PRE desde IC solo mediante PR

Nunca directamente.

### ✔ Mantener PRO como la rama más estable

Solo recibir merges desde PRE.

---

# **7. Diagrama de flujo (simple)**

```
Repositorio B (origen)
       DEV
        |
        v
Repositorio A
       DEV
   /     |     \
  v      v      v
 IC → PRE → PRO
  ^      ^      |
  |      |      |
feature → PR → merge → deploy
```

---

# **8. Resumen final**

Esta guía define:

✔ Cómo crear ramas IC, PRE y PRO desde DEV
✔ Cómo mantener el histórico íntegro sin force pushes
✔ Cómo sincronizar repositorios sin perder trazabilidad
✔ Cómo integrar la estructura con Bitbucket Pipelines
✔ Mejores prácticas de branching y PR flow

