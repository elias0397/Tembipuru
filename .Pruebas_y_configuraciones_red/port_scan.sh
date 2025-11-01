#!/bin/bash
# port_scan.sh - Escaneo básico de puertos para Tembipuru
# Autor: Elias Araujo
# (c) Tembipuru
# Uso seguro sin modificar sistema

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Validar que exista nmap
if ! command -v nmap &> /dev/null; then
    echo -e "${YELLOW}nmap no está instalado. Intentando instalar...${RESET}"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y nmap
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y nmap
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm nmap
    else
        echo -e "${RED}No se pudo instalar automáticamente. Instale nmap manualmente.${RESET}"
        exit 1
    fi
fi

intentos=0
while (( intentos < 3 )); do
    clear
    echo -e "${CYAN}=== Escaneo de Puertos con Nmap ===${RESET}"
    read -p "Introduce el host o IP a escanear o 3 veces Enter para salir: " target
    if [[ -n "$target" ]]; then
        echo -e "${GREEN}Escaneando puertos comunes en $target ...${RESET}"
        nmap -F "$target"
        echo
        read -p "Presiona Enter para volver al menú..."
        exit 0
    else
        echo -e "${YELLOW}¡Debes ingresar un host o IP!${RESET}"
        ((intentos++))
        sleep 1
    fi
    if (( intentos >= 3 )); then
        echo -e "${RED}Demasiados intentos vacíos. Regresando al menú anterior...${RESET}"
        sleep 1
        exit 0
    fi
    echo
done