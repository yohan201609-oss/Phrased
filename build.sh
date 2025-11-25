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

# Construir para web
echo "🔨 Construyendo aplicación para web..."
flutter build web --release --base-href /

echo "✅ Build completado exitosamente!"
echo "📁 Archivos generados en: build/web"

