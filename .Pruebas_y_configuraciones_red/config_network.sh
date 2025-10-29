#!/bin/bash
# config_network.sh - Herramienta segura para mostrar información de red y ofrecer acciones no destructivas
# Esta herramienta NO aplicará cambios sin confirmación explícita del usuario.

set -e

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

clear
echo -e "${CYAN}=== Pruebas y configuraciones de red (seguro) ===${RESET}"

PS3="Seleccione una acción: "
options=("Mostrar interfaces (ip a)" "Mostrar rutas (ip route)" "Mostrar DNS (resolv.conf)" "Reiniciar NetworkManager (requiere confirmación)" "Volver")

select opt in "${options[@]}"; do
  # Normalizar entrada: extraer dígitos del principio en caso de que el usuario teclee cosas como "5," o "4 " etc.
  num="$(echo "$REPLY" | sed 's/[^0-9].*$//')"
  case "$num" in
    1)
      echo -e "\n${YELLOW}Mostrando interfaces...${RESET}"
      ip a
      ;;
    2)
      echo -e "\n${YELLOW}Mostrando tabla de rutas...${RESET}"
      ip route
      ;;
    3)
      echo -e "\n${YELLOW}Contenido de /etc/resolv.conf...${RESET}"
      cat /etc/resolv.conf
      ;;
    4)
      echo -e "\n${RED}Esta acción reiniciará NetworkManager. Puede interrumpir conexiones activas.${RESET}"
      read -p "¿Desea continuar? (escriba 'SI' para confirmar): " c
      if [ "$c" != "SI" ]; then
        echo "Operación cancelada."
      else
        if command -v systemctl >/dev/null 2>&1; then
          echo "Reiniciando NetworkManager..."
          sudo systemctl restart NetworkManager
          echo "Hecho."
        else
          echo "systemctl no disponible. No se puede reiniciar NetworkManager aquí."
        fi
      fi
      ;;
    5)
      # Volver al menú anterior
      break
      ;;
    *)
      echo "Opción inválida"
      ;;
  esac
  echo
  read -p "Presione Enter para continuar..."
done
