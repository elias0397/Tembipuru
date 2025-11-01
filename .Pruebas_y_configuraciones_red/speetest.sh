#!/bin/bash
# Prueba de velocidad de conexión a Internet - Tembipuru
# Autor: Elias Araujo
# Linux Rembipuru - Suite de herramientas del sistema
# Versión: BETA
# speedtest.sh - Prueba segura de conectividad mediante ping
# No modifica la configuración del sistema; solo realiza pruebas de conectividad.
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Instalar speedtest-cli si no está disponible (multiplataforma)
if ! command -v speedtest-cli &> /dev/null; then
    echo -e "${YELLOW}speedtest-cli no está instalado. Intentando instalar...${RESET}"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y speedtest-cli
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y speedtest-cli
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --noconfirm speedtest-cli
    else
        echo -e "${RED}No se pudo instalar automáticamente. Instale speedtest-cli manualmente.${RESET}"
        exit 1
    fi
fi

    echo -e "${GREEN}Ejecutando speedtest detallado ...${RESET}"
            speedtest-cli