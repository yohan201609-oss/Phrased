#!/bin/bash

# Script de build para Netlify
# Instala Flutter y construye la aplicación para web

set -e  # Salir si hay algún error

echo "🚀 Iniciando build de Flutter para Netlify..."

# Instalar Flutter
echo "📦 Instalando Flutter..."
FLUTTER_VERSION="${FLUTTER_VERSION:-stable}"

# Descargar Flutter
cd /opt/build
if [ ! -d "flutter" ]; then
  echo "Descargando Flutter $FLUTTER_VERSION..."
  git clone https://github.com/flutter/flutter.git -b $FLUTTER_VERSION --depth 1
fi

# Agregar Flutter al PATH
export PATH="$PATH:/opt/build/flutter/bin"

# Verificar instalación
echo "✅ Verificando instalación de Flutter..."
flutter --version

# Habilitar web
echo "🌐 Habilitando soporte web..."
flutter config --enable-web

# Ir al directorio del proyecto
cd /opt/build/repo

# Obtener dependencias
echo "📚 Obteniendo dependencias de Flutter..."
flutter pub get

# Limpiar build anterior
echo "🧹 Limpiando build anterior..."
flutter clean || true

# Construir para web con más verbosidad
echo "🔨 Construyendo aplicación para web..."
echo "⚠️  Esto puede tardar varios minutos..."
flutter build web --release --base-href / --verbose 2>&1 | tee build.log || {
    echo "❌ Error durante la compilación"
    echo "📋 Últimas líneas del log:"
    tail -50 build.log || true
    echo "📋 Log completo guardado en build.log"
    exit 1
}

# Verificar que el build se completó correctamente
if [ ! -d "build/web" ]; then
    echo "❌ Error: El directorio build/web no existe después del build"
    echo "📋 Verificando estructura de directorios..."
    ls -la build/ || true
    exit 1
fi

echo "✅ Build completado exitosamente!"
echo "📁 Archivos generados en: build/web"
ls -la build/web/ | head -20

# Verificar y copiar el archivo _redirects
echo "📝 Verificando archivo _redirects..."
if [ -f "build/web/_redirects" ]; then
  echo "✅ Archivo _redirects ya existe en build/web"
  cat build/web/_redirects
elif [ -f "web/_redirects" ]; then
  echo "📋 Copiando _redirects desde web/ a build/web/"
  cp web/_redirects build/web/_redirects
  echo "✅ Archivo _redirects copiado exitosamente"
else
  echo "📝 Creando archivo _redirects en build/web/"
  echo "/* /index.html  200" > build/web/_redirects
  echo "✅ Archivo _redirects creado"
fi

# Verificar que el archivo se creó correctamente
if [ -f "build/web/_redirects" ]; then
  echo "✅ Verificación final: _redirects existe en build/web/"
  cat build/web/_redirects
else
  echo "⚠️  Advertencia: No se pudo crear _redirects, pero continuando..."
fi

