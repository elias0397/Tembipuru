#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: 0.2

# === CONFIGURACIÓN ===
BASE_DIR="$(dirname "$(realpath "$0")")"
DISK_DIR="$BASE_DIR/Discos_y_utilidades"

# Mensajes de depuración
echo "BASE_DIR: $BASE_DIR"
echo "DISK_DIR: $DISK_DIR"

# === COLORES ===
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# === PANTALLA DE PRESENTACIÓN ===
echo -e "${CYAN}"
echo "=============================================="
echo "        🐧  Linux Rembipuru CLI Suite"
echo "=============================================="
echo -e "${YELLOW} Versión 0.2 - Herramientas para el sistema"
echo -e "${RESET}"
sleep 1
for i in {1..3}; do
    echo -n "."
    sleep 0.4
done
echo
sleep 0.5
clear

# === MENÚ PRINCIPAL ===
main_menu() {
    while true; do
        clear
        echo -e "${GREEN}=== Menú principal - Linux Rembipuru ===${RESET}"
        echo "1) Actualizaciones"
        echo "2) Discos y utilidades"
        echo "3) Información del sistema"
        echo "4) Salir"
        echo
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1)
                sudo apt update && sudo apt upgrade -y
                read -p "Actualización completa. Presiona Enter..."
                ;;
            2)
                discos_menu
                ;;  
            3)
                if command -v neofetch >/dev/null 2>&1; then
                    neofetch
                else
                    echo -e "${YELLOW}Neofetch no está instalado. ¿Deseas instalarlo? (s/n)${RESET}"
                    read -n 1 -r respuesta
                    echo
                    if [[ $respuesta =~ ^[Ss]$ ]]; then
                        echo -e "${CYAN}Instalando neofetch...${RESET}"
                        sudo apt update && sudo apt install -y neofetch
                        echo -e "${GREEN}Neofetch instalado correctamente.${RESET}"
                        sleep 1
                        neofetch
                    else
                        echo -e "${YELLOW}No se instalará neofetch.${RESET}"
                    fi
                fi
                read -p "Presiona Enter para volver al menú..."
                ;;
            4)
                echo "Saliendo de Linux Rembipuru..."
                exit 0
                ;;
            *)
                echo -e "${RED}Opción inválida.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# === SUBMENÚ: DISCOS Y UTILIDADES ===
discos_menu() {
    while true; do
        clear
        echo -e "${CYAN}=== Discos y utilidades ===${RESET}"
        echo "1) Listar discos montados"
        echo "2) Ver espacio en disco"
        echo "3) Reparar Formato de disco"
        echo "4) Volver"
        echo
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1)
                lsblk -f
                ;;
            2)
                df -h
                ;;
            3)
                if [[ -f "$DISK_DIR/reparar_formato.sh" ]]; then
                    bash "$DISK_DIR/reparar_formato.sh"
                else
                    echo -e "${RED}No se encontró el script reparar_formato.sh${RESET}"
                fi
                ;;
            4)
                return
                ;;
            *)
                echo -e "${RED}Opción inválida.${RESET}"
                ;;
        esac
        echo
        read -p "Presiona Enter para continuar..."
    done
}

# === EJECUCIÓN ===
main_menu
