# Guía para Completar las Tareas de Play Console

Esta guía te ayudará a completar cada una de las tareas pendientes en Google Play Console para tu app **Phrased**.

## 📋 Tareas Pendientes

### 1. ✅ Configura la política de privacidad

**¿Por qué es obligatorio?**
- Tu app usa **Google Mobile Ads** (anuncios)
- Usa **SharedPreferences** (almacenamiento local)
- Accede a la **API de Gemini** (servicios externos)
- Usa **ImagePicker** (acceso a imágenes)

**Pasos:**
1. Crea una política de privacidad. Puedes usar:
   - [Google Sites](https://sites.google.com) (gratis)
   - [GitHub Pages](https://pages.github.com) (gratis)
   - Tu propio sitio web
   - Cualquier servicio de hosting

2. **Contenido mínimo que debe incluir:**
   ```
   - Qué datos recopilas (preferencias de idioma, uso de la app)
   - Cómo usas los datos (solo localmente, no se comparten)
   - Uso de Google Mobile Ads (recopilan datos para publicidad)
   - Uso de la API de Gemini (envías texto/imágenes para generar contenido)
   - Cómo se almacenan los datos (solo en el dispositivo)
   - Derechos del usuario
   ```

3. En Play Console:
   - Ve a **"Política de contenido"** → **"Política de privacidad"**
   - Ingresa la URL de tu política de privacidad
   - Guarda

**Ejemplo de política básica:**
Puedes crear una página simple que diga:
- "Phrased almacena preferencias de usuario localmente en el dispositivo"
- "Usamos Google Mobile Ads que pueden recopilar datos para publicidad"
- "Las imágenes y texto enviados a la API de Gemini se procesan pero no se almacenan"
- "No compartimos datos personales con terceros"

---

### 2. ✅ Acceso a apps

**¿Qué significa?**
Indica si tu app tiene restricciones de acceso que impiden a los revisores de Google probar todas las funciones.

**Para Phrased:**
- ✅ **Todas las funciones están disponibles sin restricciones**
- No requiere registro de usuario
- No requiere suscripción para usar funciones básicas
- No requiere acceso a otros dispositivos
- El límite diario de créditos NO es una restricción de acceso (es una limitación de uso)

**Pasos:**
1. Ve a **"Acceso a apps"**
2. Selecciona la primera opción:
   - ✅ **"Todas las funciones de mi app están disponibles sin restricciones de acceso"**
3. **NO selecciones** la segunda opción (funciones restringidas) porque:
   - Tu app no requiere registro
   - No hay funciones premium bloqueadas
   - Los revisores pueden probar todas las funciones sin crear cuenta

**⚠️ Importante:**
- Si seleccionas "funciones restringidas" sin necesidad, Google puede rechazar tu app
- Tu app es completamente funcional sin restricciones de acceso
- El límite diario de créditos es una limitación de uso, no una restricción de acceso

---

### 3. ✅ Anuncios

**¿Por qué es obligatorio?**
Tu app usa **Google Mobile Ads** (AdMob).

**Pasos:**
1. Ve a **"Anuncios"**
2. Selecciona: **"Sí, mi app contiene anuncios"**
3. Indica el tipo de anuncios:
   - ✅ **Anuncios de banner** (BannerAd)
   - ✅ **Anuncios recompensados** (RewardedAd)
4. Explica:
   - "La app muestra anuncios de Google AdMob"
   - "Los anuncios recompensados permiten obtener créditos adicionales"
   - "Los anuncios son opcionales y no afectan la funcionalidad principal"

---

### 4. ✅ Clasificación de contenido

**¿Qué es?**
Un cuestionario que determina la edad mínima para usar tu app.

**Para Phrased:**
- Tu app es para **generar captions para Instagram**
- No contiene contenido violento, sexual o inapropiado
- Probablemente sea **PEGI 3** o **Everyone**

**Pasos:**
1. Ve a **"Clasificación de contenido"**
2. Responde el cuestionario:
   - **Violencia**: No
   - **Contenido sexual**: No
   - **Lenguaje**: No
   - **Alcohol/Drogas**: No
   - **Apuestas**: No
   - **Compras dentro de la app**: No (si no tienes compras)
3. Google te dará una clasificación automática

---

### 5. ✅ Público objetivo

**¿Qué es?**
Define para quién está dirigida tu app.

**Para Phrased:**
- **Público objetivo**: Usuarios que quieren crear captions para redes sociales
- **Edad**: Probablemente 13+ o 17+ (depende de la clasificación de contenido)

**Pasos:**
1. Ve a **"Público objetivo"**
2. Selecciona:
   - **Edad mínima**: Según la clasificación de contenido
   - **Categoría**: "Productividad" o "Estilo de vida"
   - **Descripción**: "App para generar captions creativos para Instagram y redes sociales"

---

### 6. ✅ Seguridad de los datos

**¿Qué es?**
Declaración sobre qué datos recopila tu app y cómo los proteges.

**Para Phrased:**

**Datos que recopilas:**
- ✅ **Preferencias de usuario** (idioma, tema) - Almacenados localmente
- ✅ **Uso de la app** (créditos diarios) - Almacenados localmente
- ✅ **Datos de anuncios** (Google AdMob) - Recopilados por Google

**Datos que NO recopilas:**
- ❌ Información personal identificable
- ❌ Ubicación
- ❌ Contactos
- ❌ Archivos del dispositivo (excepto imágenes seleccionadas por el usuario)

**Pasos:**
1. Ve a **"Seguridad de los datos"**
2. Para cada tipo de dato:
   - **Preferencias de usuario**: 
     - ¿Recopilas? Sí (localmente)
     - ¿Compartes? No
     - ¿Encriptas? No necesario (solo local)
   
   - **Datos de anuncios**:
     - ¿Recopilas? Sí (Google AdMob)
     - ¿Compartes? Sí (con Google para publicidad)
     - ¿Encriptas? Sí (Google maneja la encriptación)

3. **Declaración de uso de datos:**
   - "Los datos se usan solo para mejorar la experiencia del usuario"
   - "Los datos de anuncios son manejados por Google AdMob"
   - "No vendemos ni compartimos datos personales"

---

### 7. ✅ Apps gubernamentales

**¿Aplica?**
Solo si tu app es para uso gubernamental.

**Para Phrased:**
- **No aplica** - Es una app comercial/personal
- Puedes omitir esta sección o seleccionar "No"

---

## 📝 Resumen Rápido

| Tarea | Respuesta para Phrased |
|-------|------------------------|
| **Política de privacidad** | ✅ Obligatorio - Crear y subir URL |
| **Acceso a apps** | Todas las funciones disponibles sin restricciones |
| **Anuncios** | ✅ Sí, contiene anuncios (AdMob) |
| **Clasificación de contenido** | PEGI 3 / Everyone (sin contenido inapropiado) |
| **Público objetivo** | 13+ o 17+, Productividad/Estilo de vida |
| **Seguridad de los datos** | Preferencias locales + Datos de AdMob |
| **Apps gubernamentales** | No aplica |

---

## 🚀 Orden Recomendado

1. **Primero**: Crear y subir la política de privacidad
2. **Segundo**: Completar "Seguridad de los datos" (necesita la política)
3. **Tercero**: Configurar "Anuncios"
4. **Cuarto**: Completar "Clasificación de contenido"
5. **Quinto**: Configurar "Público objetivo"
6. **Sexto**: Configurar "Acceso a apps"
7. **Séptimo**: "Apps gubernamentales" (si aplica)

---

## ⚠️ Importante

- **No puedes publicar** hasta completar todas las tareas obligatorias
- La **política de privacidad** es obligatoria si usas anuncios
- **Seguridad de los datos** es obligatoria desde 2022
- Las respuestas deben ser **precisas y honestas**

---

## 📚 Recursos Útiles

- [Política de privacidad de Google](https://policies.google.com/privacy)
- [Guía de AdMob sobre privacidad](https://support.google.com/admob/answer/6128543)
- [Plantilla de política de privacidad](https://www.privacypolicygenerator.info/)

---

¡Completa estas tareas y estarás listo para publicar tu app! 🎉

