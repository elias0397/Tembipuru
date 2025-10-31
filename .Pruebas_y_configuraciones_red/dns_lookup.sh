#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# dns_lookup.sh - Resuelve un dominio usando dig o host
TARGET=""
if [ $# -ge 1 ]; then
  TARGET="$1"
else
  echo -e "\e[36mIngrese el dominio a resolver (ejemplo: google.com):\e[0m "
  read -r TARGET
  if [ -z "$TARGET" ]; then
    TARGET="google.com"
    echo -e "\e[33mNo se ingresó dominio, usando valor por defecto: $TARGET\e[0m"
  fi
fi

echo "Resolviendo: $TARGET"
# Cargar helper común
source "$(dirname "$(realpath "$0")")/helpers.sh" || { echo "No se pudo cargar helpers.sh"; exit 1; }

if check_and_install dig dnsutils; then
  dig +noall +answer "$TARGET"
elif check_and_install host dnsutils; then
  host "$TARGET"
else
  echo "Ni 'dig' ni 'host' están disponibles y no se instalaron. Abortando."
  exit 1
fi

if [ $? -eq 0 ]; then
  echo "\nResultado: Resolución realizada"
else
  echo "\nResultado: Error en resolución"
fi
