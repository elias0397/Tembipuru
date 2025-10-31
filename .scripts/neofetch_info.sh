#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# neofetch_info.sh - Muestra la información del sistema con neofetch (instala si el usuario acepta)

if command -v neofetch >/dev/null 2>&1; then
  neofetch
else
  echo "Neofetch no está instalado."
  read -p "¿Deseas instalarlo? (s/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Ss]$ ]]; then
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y neofetch
    elif command -v dnf >/dev/null 2>&1; then
      sudo dnf install -y neofetch
    elif command -v pacman >/dev/null 2>&1; then
      sudo pacman -Sy neofetch --noconfirm
    elif command -v zypper >/dev/null 2>&1; then
      sudo zypper install -y neofetch
    else
      echo "No se puede instalar automáticamente en esta plataforma."
      exit 1
    fi
    neofetch
  else
    echo "No se instalará neofetch."
  fi
fi

read -p "Presiona Enter para volver al menú..."