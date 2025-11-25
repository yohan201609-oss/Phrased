# Solución de Problemas - Error 404 en Netlify

Esta guía te ayudará a resolver el error "Sitio no encontrado" (404) en Netlify para tu aplicación Flutter.

## 🔍 Diagnóstico del Problema

El error 404 en Netlify generalmente ocurre por una de estas razones:

1. **Build no completado correctamente** ⚠️ **MÁS COMÚN**
2. **Flutter no encontrado en el entorno de build** ⚠️ **ERROR FRECUENTE**
3. **Archivos no generados en `build/web`**
4. **Configuración de redirecciones incorrecta**
5. **Base href no configurado correctamente**
6. **Sitio no desplegado o despliegue fallido**

### ⚠️ Error Específico: "flutter: comando no encontrado"

Si ves este error en los logs:
```
bash: línea 1: flutter: comando no encontrado
Error durante la etapa 'sitio de construcción': el script de construcción devolvió un código de salida distinto de cero: 2
```

**Causa:** Netlify no incluye Flutter por defecto en su entorno de build.

**Solución Implementada:** 
El proyecto ahora incluye un script `build.sh` que instala Flutter automáticamente. El archivo `netlify.toml` está configurado para usar este script.

**Verifica que:**
- ✅ El archivo `build.sh` existe en la raíz del proyecto
- ✅ El archivo `netlify.toml` tiene `command = "bash build.sh"`
- ✅ Los archivos están subidos a tu repositorio de GitHub

---

## ✅ Soluciones Paso a Paso

### 1. Verificar el Estado del Build

1. Ve a tu panel de Netlify: [app.netlify.com](https://app.netlify.com)
2. Selecciona tu sitio
3. Ve a la pestaña **"Deploys"**
4. Revisa el último despliegue:
   - ✅ **Success**: El build se completó correctamente
   - ❌ **Failed**: Hay un error en el build
   - ⏳ **Building**: Aún está en proceso

**Si el build falló:**
- Haz clic en el despliegue fallido para ver los logs
- Busca errores relacionados con Flutter o el build
- Copia los mensajes de error para diagnosticar

### 2. Verificar que Flutter esté Disponible

Netlify Build Image incluye Flutter, pero a veces puede no estar disponible. Verifica en los logs del build si aparece:

```
Flutter not found
```

**Solución:**
1. Ve a **Site settings** > **Build & deploy** > **Environment**
2. Agrega la variable de entorno:
   - **Key**: `FLUTTER_VERSION`
   - **Value**: `stable`
3. Guarda y vuelve a desplegar

### 3. Verificar la Configuración del Build

Asegúrate de que en Netlify esté configurado:

1. Ve a **Site settings** > **Build & deploy** > **Build settings**
2. Verifica:
   - **Build command**: `flutter build web --release`
   - **Publish directory**: `build/web`
3. Si no coincide, actualízalo y guarda

### 4. Probar Build Localmente

Antes de desplegar, prueba construir localmente:

```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Construir para web
flutter build web --release
```

**Verifica que se generaron los archivos:**
```bash
# En Windows PowerShell
Test-Path build/web/index.html
# Debe retornar True

# Listar archivos en build/web
Get-ChildItem build/web
```

**Archivos esperados en `build/web`:**
- `index.html`
- `main.dart.js` (o archivos JS compilados)
- `assets/`
- `manifest.json`
- `favicon.png`

### 5. Verificar Base Href

El archivo `web/index.html` tiene:
```html
<base href="$FLUTTER_BASE_HREF">
```

Flutter debería reemplazar esto durante el build. Si no se reemplaza:

**Solución temporal:**
Edita `web/index.html` y cambia temporalmente a:
```html
<base href="/">
```

**Solución permanente:**
Asegúrate de construir con:
```bash
flutter build web --release --base-href /
```

O actualiza `netlify.toml`:
```toml
[build]
  command = "flutter build web --release --base-href /"
```

### 6. Verificar Redirecciones en netlify.toml

Tu `netlify.toml` ya tiene redirecciones configuradas, pero verifica que estén correctas:

```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

Esta configuración debería funcionar. Si no, prueba con:

```toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
  force = true
```

### 7. Re-desplegar el Sitio

Si todo lo anterior está correcto, intenta re-desplegar:

**Opción A: Desde Netlify**
1. Ve a **Deploys**
2. Haz clic en **"Trigger deploy"** > **"Clear cache and deploy site"**

**Opción B: Desde GitHub**
1. Haz un pequeño cambio en tu código (ej: un comentario)
2. Haz commit y push:
```bash
git add .
git commit -m "Trigger redeploy"
git push
```

### 8. Despliegue Manual como Prueba

Para verificar que el build funciona:

1. Construye localmente:
```bash
flutter build web --release
```

2. Ve a [Netlify Drop](https://app.netlify.com/drop)
3. Arrastra la carpeta `build/web` completa
4. Si funciona, el problema está en la configuración del build automático

---

## 🔧 Configuración Actual de netlify.toml

El proyecto ahora usa un script de build que instala Flutter automáticamente:

```toml
[build]
  command = "bash build.sh"
  publish = "build/web"

[build.environment]
  FLUTTER_VERSION = "stable"
```

El script `build.sh`:
- Instala Flutter desde GitHub
- Configura el PATH
- Habilita soporte web
- Obtiene dependencias
- Construye la aplicación

Si necesitas usar una versión específica de Flutter, cambia `FLUTTER_VERSION` en `netlify.toml` o en las variables de entorno de Netlify.

**Configuración alternativa (si build.sh no funciona):**

```toml
[build]
  command = "flutter build web --release --base-href /"
  publish = "build/web"

[build.environment]
  FLUTTER_VERSION = "stable"

# Redirecciones para SPA
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
  force = true

# Headers de seguridad
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"

[[headers]]
  for = "/*.js"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/*.css"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"

[[headers]]
  for = "/assets/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

**Cambios principales:**
- Agregado `--base-href /` al comando de build
- Agregado `force = true` a las redirecciones

---

## 🐛 Errores Comunes y Soluciones

### Error: "Flutter: command not found" o "bash: línea 1: flutter: comando no encontrado"

**Causa:** Netlify no incluye Flutter por defecto en su entorno de build.

**Solución:**
El proyecto ahora incluye un script `build.sh` que instala Flutter automáticamente antes de construir. Asegúrate de que:
1. El archivo `build.sh` existe en la raíz del proyecto
2. El archivo `netlify.toml` está configurado para usar `bash build.sh`
3. La variable de entorno `FLUTTER_VERSION = "stable"` está configurada en Netlify (opcional, por defecto usa "stable")

Si el problema persiste:
- Verifica que el script tenga permisos de ejecución (se agrega automáticamente en Git)
- Revisa los logs del build para ver si hay errores en la instalación de Flutter

### Error: "Build timeout"

**Solución:**
1. Ve a **Site settings** > **Build & deploy** > **Build settings**
2. Aumenta el timeout si es posible
3. O optimiza el build eliminando dependencias innecesarias

### Error: "Directory build/web not found"

**Solución:**
1. Verifica que el build se complete correctamente
2. Revisa los logs del build en Netlify
3. Asegúrate de que `publish = "build/web"` esté correcto

### La página carga pero muestra contenido en blanco

**Solución:**
1. Abre la consola del navegador (F12) y revisa errores
2. Verifica que los archivos JS se carguen correctamente
3. Verifica que el base href esté configurado como `/`

### Error: "CORS policy" o problemas con assets

**Solución:**
1. Verifica que los assets estén en `pubspec.yaml`
2. Asegúrate de que las rutas de assets sean relativas
3. Verifica los headers en `netlify.toml`

---

## 📋 Checklist de Verificación

Antes de reportar el problema, verifica:

- [ ] El build se completa sin errores en Netlify
- [ ] Los archivos se generan en `build/web` localmente
- [ ] `index.html` existe en `build/web`
- [ ] `netlify.toml` está en la raíz del proyecto
- [ ] La configuración de build en Netlify coincide con `netlify.toml`
- [ ] La variable `FLUTTER_VERSION` está configurada en Netlify
- [ ] El repositorio está conectado correctamente a Netlify
- [ ] Has intentado limpiar la caché y re-desplegar

---

## 🆘 Obtener Ayuda Adicional

Si el problema persiste:

1. **Revisa los logs completos del build** en Netlify
2. **Prueba construir localmente** y verifica que funcione
3. **Consulta la documentación de Netlify**: [docs.netlify.com](https://docs.netlify.com)
4. **Consulta la documentación de Flutter Web**: [docs.flutter.dev/deployment/web](https://docs.flutter.dev/deployment/web)
5. **Revisa el foro de Netlify**: [answers.netlify.com](https://answers.netlify.com)

---

## 🔄 Proceso de Depuración Recomendado

1. **Construir localmente** y verificar que funciona
2. **Revisar logs del build** en Netlify
3. **Verificar configuración** en Netlify vs `netlify.toml`
4. **Limpiar caché** y re-desplegar
5. **Probar despliegue manual** con Netlify Drop
6. **Actualizar configuración** si es necesario
7. **Re-desplegar** y verificar

---

¡Espero que esto resuelva tu problema! Si necesitas más ayuda, comparte los logs del build de Netlify.

