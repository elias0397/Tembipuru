#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# helpers.sh - Funciones compartidas para Pruebas_y_configuraciones_red

# Detectar gestor de paquetes
detect_pkg_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v zypper >/dev/null 2>&1; then
    echo "zypper"
  else
    echo "unknown"
  fi
}

# check_and_install <cmd> <pkg>
# - cmd: comando a verificar (ej: dig)
# - pkg: nombre del paquete para instalar (preferiblemente para apt). Para otros gestores
#        se intentará usar el mismo nombre y se advertirá al usuario.
check_and_install() {
  local cmd="$1"
  local pkg="$2"

  if [ -z "$cmd" ] || [ -z "$pkg" ]; then
    echo "Uso: check_and_install <comando> <paquete>"
    return 2
  fi

  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  local pm
  pm=$(detect_pkg_manager)

  case "$pm" in
    apt)
      install_cmd_str="sudo apt-get update && sudo apt-get install -y $pkg"
      ;;
    dnf)
      install_cmd_str="sudo dnf install -y $pkg"
      ;;
    pacman)
      install_cmd_str="sudo pacman -Sy $pkg"
      ;;
    zypper)
      install_cmd_str="sudo zypper install -y $pkg"
      ;;
    *)
      echo "No se detectó un gestor de paquetes conocido. Por favor instala '$pkg' manualmente." >&2
      return 1
      ;;
  esac

  echo "El comando '$cmd' no está instalado. El script propone ejecutar:"
  echo
  # Mostrar el comando de instalación propuesto
  if [ -n "$install_cmd_str" ]; then
    echo "$install_cmd_str"
  fi
  echo
  read -p "¿Desea instalar '$pkg' ahora? (s/n): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Ss]$ ]]; then
    if [ "$pm" = "apt" ]; then
      sudo apt-get update && sudo apt-get install -y "$pkg"
      return $?
    elif [ "$pm" = "dnf" ]; then
      sudo dnf install -y "$pkg"
      return $?
    elif [ "$pm" = "pacman" ]; then
      sudo pacman -Sy "$pkg"
      return $?
    elif [ "$pm" = "zypper" ]; then
      sudo zypper install -y "$pkg"
      return $?
    else
      echo "Instalación no soportada automáticamente en esta plataforma." >&2
      return 1
    fi
  else
    echo "No se instaló '$pkg'."
    return 1
  fi
}
