# Phrased

Aplicación Flutter multiplataforma para gestión de frases y expresiones.

## Características

- 🌐 Soporte multiidioma (Español/Inglés)
- 🌓 Modo oscuro/claro
- 📱 Compatible con Android, iOS, Web, Windows, macOS y Linux
- 🎨 Interfaz moderna y responsive

## Requisitos

- Flutter SDK 3.10.0 o superior
- Dart SDK compatible

## Instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/phrased.git
cd phrased
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## Despliegue

### GitHub

1. Inicializa el repositorio Git (si no está inicializado):
```bash
git init
```

2. Agrega todos los archivos:
```bash
git add .
```

3. Crea el primer commit:
```bash
git commit -m "Initial commit"
```

4. Crea un nuevo repositorio en GitHub y luego conecta tu repositorio local:
```bash
git remote add origin https://github.com/tu-usuario/phrased.git
git branch -M main
git push -u origin main
```

### Netlify

#### Opción 1: Despliegue desde GitHub (Recomendado)

1. Ve a [Netlify](https://www.netlify.com/) e inicia sesión
2. Haz clic en "Add new site" > "Import an existing project"
3. Conecta tu repositorio de GitHub
4. Netlify detectará automáticamente la configuración desde `netlify.toml`
5. Configura las variables de entorno si es necesario
6. Haz clic en "Deploy site"

#### Opción 2: Despliegue manual

1. Construye la aplicación para web:
```bash
flutter build web --release
```

2. Arrastra la carpeta `build/web` a [Netlify Drop](https://app.netlify.com/drop)

#### Configuración en Netlify

El archivo `netlify.toml` ya está configurado con:
- Comando de build: `flutter build web --release`
- Directorio de publicación: `build/web`
- Redirecciones para SPA
- Headers de seguridad

**Nota importante**: Netlify Build Image incluye Flutter, pero si necesitas una versión específica, puedes configurarla en las variables de entorno del sitio en Netlify.

## Estructura del Proyecto

```
phrased/
├── lib/
│   ├── core/          # Configuración core (tema, localización)
│   ├── services/      # Servicios de la aplicación
│   ├── ui/            # Pantallas y widgets
│   └── main.dart      # Punto de entrada
├── assets/            # Recursos (imágenes, iconos)
├── web/               # Configuración web
└── netlify.toml       # Configuración de Netlify
```

## Desarrollo

Para ejecutar en modo desarrollo:
```bash
flutter run -d chrome  # Para web
flutter run -d android # Para Android
flutter run -d ios     # Para iOS
```

## Licencia

Este proyecto es privado y no está destinado a ser publicado en pub.dev.
