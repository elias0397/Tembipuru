#!/bin/bash
# network_services.sh - Muestra el estado simplificado de la red

# === COLORES ===
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
RESET="\e[0m"

# === FUNCIONES ===
check_network_service() {
    echo -e "${CYAN}Estado del servicio de red:${RESET}"
    
    # Lista de servicios comunes de red
    services=(
        "NetworkManager"     # Común en muchas distros modernas
        "systemd-networkd"   # Usado en sistemas con systemd
        "networking"         # Común en Debian/Ubuntu
        "network"           # Común en Red Hat/CentOS
        "network"           # Algunas variantes
        "wicd"             # Alternativa ligera
        "connman"          # Common en sistemas embebidos
    )
    
    service_found=false
    
    for service in "${services[@]}"; do
        if systemctl list-unit-files "${service}.service" &>/dev/null; then
            service_found=true
            if systemctl is-active --quiet "${service}.service"; then
                echo -e "- ${service}: ${GREEN}ACTIVO${RESET}"
            else
                echo -e "- ${service}: ${RED}INACTIVO${RESET}"
            fi
        fi
    done
    
    if [ "$service_found" = false ]; then
        # Verificar interfaces de red directamente si no se encuentra ningún servicio
        if ip route get 1.1.1.1 &>/dev/null; then
            echo -e "${GREEN}✅ Red funcionando (servicio no detectado)${RESET}"
        else
            echo -e "${RED}❌ Sin conexión de red${RESET}"
        fi
    fi
}

check_interfaces() {
    echo -e "\n${CYAN}Estado de interfaces de red:${RESET}"
    ip -br link | while read -r line; do
        if_name=$(echo "$line" | awk '{print $1}')
        if_state=$(echo "$line" | awk '{print $2}')
        
        if [[ "$if_state" == *"UP"* ]]; then
            echo -e "- ${if_name}: ${GREEN}ACTIVA${RESET}"
        else
            echo -e "- ${if_name}: ${RED}INACTIVA${RESET}"
        fi
    done
}

# === EJECUCIÓN ===
echo -e "${CYAN}=== Estado de Red ===${RESET}\n"
check_network_service
check_interfaces

read -p "Presiona Enter para continuar..."