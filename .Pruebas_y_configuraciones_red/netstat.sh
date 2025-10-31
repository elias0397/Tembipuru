#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# check_ports.sh - Verifica puertos escuchando con netstat (instala net-tools si el usuario acepta)

HELPERS_DIR="$(dirname "$(realpath "$0")")"
if [[ -f "$HELPERS_DIR/helpers.sh" ]]; then
  source "$HELPERS_DIR/helpers.sh"
fi

if ! command -v netstat >/dev/null 2>&1; then
  echo "netstat no está disponible. Se intentará instalar net-tools."
  if declare -f check_and_install >/dev/null 2>&1; then
    check_and_install netstat net-tools || true
  else
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y net-tools || true
    else
      echo "No se puede instalar automáticamente en esta plataforma. Por favor instala 'net-tools'."
    fi
  fi
fi

echo "Mostrando puertos en escucha (tcp/udp):"
sudo netstat -tuln

read -p "Presiona Enter para continuar..."