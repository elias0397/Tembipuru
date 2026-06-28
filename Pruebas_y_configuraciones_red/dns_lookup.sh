#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# dns_lookup.sh - Resuelve un dominio usando dig o host
TARGET=""
RECTYPE="A"
if [ $# -ge 1 ]; then
  TARGET="$1"
  if [ $# -ge 2 ]; then
    RECTYPE="$2"
  fi
else
  echo -e "\e[36mIngrese el dominio a resolver (ejemplo: google.com):\e[0m "
  read -r TARGET
  if [ -z "$TARGET" ]; then
    TARGET="google.com"
    echo -e "\e[33mNo se ingresó dominio, usando valor por defecto: $TARGET\e[0m"
  fi

  echo -e "\e[36mIngrese el tipo de registro DNS (A, AAAA, MX, CNAME, TXT, NS, ANY) [Por defecto: A]:\e[0m "
  read -r RECTYPE
  RECTYPE=$(echo "$RECTYPE" | tr '[:lower:]' '[:upper:]')
  if [ -z "$RECTYPE" ]; then
    RECTYPE="A"
  fi
fi

echo "Resolviendo registro $RECTYPE para: $TARGET"
# Cargar helper común
source "$(dirname "$(realpath "$0")")/helpers.sh" || { echo "No se pudo cargar helpers.sh"; exit 1; }

if check_and_install dig dnsutils; then
  dig +noall +answer "$TARGET" "$RECTYPE"
elif check_and_install host dnsutils; then
  host -t "$RECTYPE" "$TARGET"
else
  echo "Ni 'dig' ni 'host' están disponibles y no se instalaron. Abortando."
  exit 1
fi

if [ $? -eq 0 ]; then
  echo -e "\nResultado: Resolución realizada"
else
  echo -e "\nResultado: Error en resolución"
fi
