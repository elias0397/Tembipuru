#!/bin/bash
# traceroute_test.sh - Prueba de ruta hasta un host (usa traceroute o tracepath)
TARGET=""

# Si se pasa como argumento, usarlo; si no, pedirlo interactivamente.
if [ $# -ge 1 ]; then
  TARGET="$1"
else
  echo -e "\e[36mIngrese el host o IP a rastrear (por defecto: google.com):\e[0m "
  read -r TARGET
  if [ -z "$TARGET" ]; then
    TARGET="google.com"
    echo -e "\e[33mNo se ingresó destino, usando: $TARGET\e[0m"
  fi
fi

echo "Ejecutando traceroute/tracepath hacia: $TARGET"
# Cargar helper común
source "$(dirname "$(realpath "$0")")/helpers.sh" || { echo "No se pudo cargar helpers.sh"; exit 1; }

if command -v traceroute >/dev/null 2>&1; then
  traceroute "$TARGET"
elif command -v tracepath >/dev/null 2>&1; then
  tracepath "$TARGET"
elif check_and_install traceroute traceroute; then
  traceroute "$TARGET"
else
  echo "Ni 'traceroute' ni 'tracepath' están disponibles y no se instalaron. Abortando."
  exit 1
fi

if [ $? -eq 0 ]; then
  echo "\nResultado: Rastreado completado"
else
  echo "\nResultado: Error al rastrear la ruta"
fi
