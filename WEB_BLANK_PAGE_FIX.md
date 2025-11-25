# Solución: Página en Blanco en Web

Esta guía te ayudará a diagnosticar y resolver el problema de la página en blanco después del despliegue en Netlify.

## 🔍 Diagnóstico

### Paso 1: Verificar la Consola del Navegador

1. Abre tu sitio en el navegador: `https://phrased-web.netlify.app`
2. Presiona **F12** o **Ctrl+Shift+I** para abrir las herramientas de desarrollador
3. Ve a la pestaña **"Console"**
4. Busca errores en rojo

**Errores comunes:**
- `Failed to load resource` - Archivos no encontrados
- `Uncaught TypeError` - Error de JavaScript
- `CORS policy` - Problema de permisos
- `SharedPreferences` errors - Problema con almacenamiento local

### Paso 2: Verificar la Pestaña Network

1. En las herramientas de desarrollador, ve a la pestaña **"Network"**
2. Recarga la página (F5)
3. Verifica que estos archivos se carguen correctamente:
   - ✅ `flutter_bootstrap.js` - Debe ser 200 (OK)
   - ✅ `main.dart.js` - Debe ser 200 (OK)
   - ✅ `flutter.js` - Debe ser 200 (OK)
   - ✅ `canvaskit.js` - Debe ser 200 (OK)

**Si algún archivo muestra 404:**
- El problema es con las rutas o el base href
- Verifica que el build se completó correctamente

### Paso 3: Verificar el Base Href

1. Abre el código fuente de la página (Ctrl+U)
2. Busca la línea: `<base href="...">`
3. Debe ser: `<base href="/">`

**Si es diferente:**
- El problema está en la configuración del build
- Verifica `netlify.toml` y `build.sh`

## ✅ Soluciones

### Solución 1: Limpiar Caché del Navegador

1. Presiona **Ctrl+Shift+Delete**
2. Selecciona "Caché" o "Cached images and files"
3. Haz clic en "Borrar datos"
4. Recarga la página (Ctrl+F5 para forzar recarga)

### Solución 2: Verificar el Build en Netlify

1. Ve a tu panel de Netlify
2. Revisa los logs del último despliegue
3. Verifica que no haya errores durante el build
4. Asegúrate de que el build se completó exitosamente

### Solución 3: Verificar Archivos Generados

El build debe generar estos archivos en `build/web`:
- `index.html`
- `main.dart.js`
- `flutter_bootstrap.js`
- `flutter.js`
- `assets/` (carpeta con recursos)

**Si faltan archivos:**
- El build no se completó correctamente
- Revisa los logs de Netlify

### Solución 4: Probar en Modo Incógnito

1. Abre una ventana de incógnito (Ctrl+Shift+N)
2. Visita tu sitio
3. Si funciona en incógnito, el problema es la caché del navegador

### Solución 5: Verificar Service Worker

1. En las herramientas de desarrollador, ve a **Application** > **Service Workers**
2. Si hay un service worker registrado, haz clic en **"Unregister"**
3. Recarga la página

### Solución 6: Verificar SharedPreferences

Si ves errores relacionados con `SharedPreferences`:

1. Abre la consola del navegador
2. Ejecuta: `localStorage.clear()`
3. Recarga la página

## 🐛 Errores Específicos y Soluciones

### Error: "Failed to load resource: flutter_bootstrap.js"

**Causa:** El archivo no se encuentra o la ruta es incorrecta.

**Solución:**
1. Verifica que el build se completó correctamente
2. Revisa que `netlify.toml` tenga `publish = "build/web"`
3. Verifica que el base href sea `/`

### Error: "Uncaught TypeError: Cannot read property..."

**Causa:** Error de JavaScript, posiblemente relacionado con una dependencia.

**Solución:**
1. Revisa los logs completos en la consola
2. Verifica que todas las dependencias estén actualizadas
3. Prueba construir localmente: `flutter build web --release`

### Error: "SharedPreferences.getInstance() failed"

**Causa:** Problema con el almacenamiento local en web.

**Solución:**
1. Limpia el localStorage: `localStorage.clear()` en la consola
2. Verifica que el navegador permita almacenamiento local
3. Prueba en otro navegador

### Página se queda en el splash screen

**Causa:** La aplicación no está cargando correctamente.

**Solución:**
1. Abre la consola y busca errores
2. Verifica que `main.dart.js` se cargue correctamente
3. Revisa los logs de Netlify para errores de compilación

## 🔧 Verificación Local

Antes de desplegar, prueba localmente:

```bash
# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Construir para web
flutter build web --release --base-href /

# Servir localmente (opcional)
cd build/web
python -m http.server 8000
# O usar: npx serve
```

Luego visita `http://localhost:8000` y verifica que funcione.

## 📋 Checklist de Verificación

Antes de reportar el problema, verifica:

- [ ] La consola del navegador no muestra errores
- [ ] Todos los archivos JS se cargan (Network tab)
- [ ] El base href es `/` en el HTML generado
- [ ] El build en Netlify se completó sin errores
- [ ] Probaste en modo incógnito
- [ ] Limpiaste la caché del navegador
- [ ] Probaste en otro navegador
- [ ] El build local funciona correctamente

## 🆘 Obtener Más Información

Si el problema persiste:

1. **Captura de pantalla de la consola** con todos los errores
2. **Logs del build de Netlify** (último despliegue)
3. **Información del navegador** (versión, sistema operativo)
4. **URL del sitio** que no funciona

## 🔄 Próximos Pasos

1. **Re-desplegar** después de limpiar caché
2. **Verificar logs** en Netlify
3. **Probar en diferentes navegadores** (Chrome, Firefox, Edge)
4. **Verificar en diferentes dispositivos** (móvil, tablet, desktop)

---

**Nota:** Si después de seguir estos pasos el problema persiste, comparte:
- Captura de pantalla de la consola del navegador
- Logs del build de Netlify
- URL del sitio

¡Esto ayudará a diagnosticar el problema más rápidamente!

