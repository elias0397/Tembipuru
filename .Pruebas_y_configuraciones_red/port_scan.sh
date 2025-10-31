#!/bin/bash
# port_scan.sh - Escaneo de puertos usando nmap

# === COLORES ===
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# Puertos comunes para escanear
COMMON_PORTS="21,22,23,25,53,80,110,139,443,445,3306,3389,5432,8080"

# Función para validar IP/dominio
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    elif [[ $ip =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# === INTERFAZ ===
echo -e "${CYAN}=== Escáner de Puertos (Nmap) ===${RESET}\n"

# Solicitar el objetivo
while true; do
    read -p "Ingresa la IP o dominio objetivo: " HOST
    if validate_ip "$HOST"; then
        break
    else
        echo -e "${RED}Error: Ingresa una IP o dominio válido${RESET}"
    fi
done

# Solicitar puertos (opcional)
echo -e "\n${YELLOW}Puertos a escanear (presiona Enter para usar puertos comunes):${RESET}"
echo -e "${CYAN}Formato: 80,443,8080 o rangos como 80-100${RESET}"
read -p "Puertos: " PORTS

# Si no se especifican puertos, usar los comunes
if [ -z "$PORTS" ]; then
    PORTS=$COMMON_PORTS
    echo -e "\n${YELLOW}Usando puertos comunes: $COMMON_PORTS${RESET}"
fi

echo -e "\n${GREEN}Iniciando escaneo de $HOST en los puertos: $PORTS ${RESET}\n"

# Verificar si nmap está instalado
if ! command -v nmap &> /dev/null; then
    echo -e "${RED}Nmap no está instalado. Instalando...${RESET}"
    sudo apt update && sudo apt install -y nmap
fi

# Ejecutar el escaneo con detección de versión
sudo nmap -p"$PORTS" -sV "$HOST"

read -p "Presiona Enter para continuar..."
