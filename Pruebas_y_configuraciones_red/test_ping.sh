#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# test_ping.sh - Prueba segura de conectividad mediante ping
# No modifica la configuración del sistema; solo realiza pruebas de conectividad.

TARGET=""
COUNT=4

# Si se pasa como argumento, usarlo; si no, pedirlo interactivamente.
if [ $# -ge 1 ]; then
  TARGET="$1"
else
  echo -e "\e[36mIngrese el host o IP a hacer ping (por defecto: 8.8.8.8):\e[0m "
  read -r TARGET
  if [ -z "$TARGET" ]; then
    TARGET="8.8.8.8"
    echo -e "\e[33mNo se ingresó destino, usando: $TARGET\e[0m"
  fi
fi

ping -c "$COUNT" "$TARGET"

# Salida amigable
if [ $? -eq 0 ]; then
  echo "\nResultado: Conectividad OK"
else
  echo "\nResultado: No se pudo alcanzar el destino"
fi
