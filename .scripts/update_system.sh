#!/bin/bash
# update_system.sh - Actualiza el sistema usando el gestor de paquetes disponible

set -e

echo "Iniciando actualización del sistema..."
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get upgrade -y
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf upgrade --refresh -y
elif command -v pacman >/dev/null 2>&1; then
  sudo pacman -Syu --noconfirm
elif command -v zypper >/dev/null 2>&1; then
  sudo zypper refresh && sudo zypper update -y
else
  echo "No se detectó un gestor de paquetes compatible. Abortando."
  exit 1
fi

read -p "Actualización completa. Presiona Enter..."