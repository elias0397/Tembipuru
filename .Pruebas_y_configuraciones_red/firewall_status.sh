#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# firewall_status.sh - Muestra el estado del firewall y sus reglas

# === COLORES ===
GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
YELLOW="\e[33m"
RESET="\e[0m"

# === FUNCIONES ===
check_firewall_type() {
    # Verifica qué firewall está en uso
    if command -v ufw >/dev/null 2>&1; then
        echo "ufw"
    elif command -v firewall-cmd >/dev/null 2>&1; then
        echo "firewalld"
    elif command -v iptables >/dev/null 2>&1; then
        echo "iptables"
    else
        echo "none"
    fi
}

show_ufw_status() {
    echo -e "${CYAN}=== Estado de UFW ===${RESET}"
    if sudo ufw status verbose | grep -q "Status: active"; then
        echo -e "${GREEN}✅ UFW está ACTIVO${RESET}"
    else
        echo -e "${RED}❌ UFW está INACTIVO${RESET}"
    fi
    echo -e "\n${CYAN}Reglas configuradas:${RESET}"
    sudo ufw status verbose | grep -v "Status:"
}

show_firewalld_status() {
    echo -e "${CYAN}=== Estado de FirewallD ===${RESET}"
    if sudo firewall-cmd --state 2>/dev/null | grep -q "running"; then
        echo -e "${GREEN}✅ FirewallD está ACTIVO${RESET}"
    else
        echo -e "${RED}❌ FirewallD está INACTIVO${RESET}"
    fi
    
    echo -e "\n${CYAN}Zonas activas:${RESET}"
    sudo firewall-cmd --get-active-zones
    
    echo -e "\n${CYAN}Servicios permitidos en zona default:${RESET}"
    sudo firewall-cmd --list-services
    
    echo -e "\n${CYAN}Puertos abiertos:${RESET}"
    sudo firewall-cmd --list-ports
}

show_iptables_status() {
    echo -e "${CYAN}=== Estado de IPTables ===${RESET}"
    echo -e "\n${CYAN}Reglas IPv4:${RESET}"
    sudo iptables -L -v -n
    
    if command -v ip6tables >/dev/null 2>&1; then
        echo -e "\n${CYAN}Reglas IPv6:${RESET}"
        sudo ip6tables -L -v -n
    fi
}

# === EJECUCIÓN PRINCIPAL ===
echo -e "${CYAN}=== Estado del Firewall ===${RESET}\n"

FIREWALL_TYPE=$(check_firewall_type)

case $FIREWALL_TYPE in
    "ufw")
        show_ufw_status
        ;;
    "firewalld")
        show_firewalld_status
        ;;
    "iptables")
        show_iptables_status
        ;;
    "none")
        echo -e "${YELLOW}⚠️ No se detectó ningún firewall instalado${RESET}"
        echo -e "Firewalls comunes:"
        echo -e "- UFW (Ubuntu/Debian)"
        echo -e "- FirewallD (Red Hat/CentOS)"
        echo -e "- IPTables (base)"
        ;;
esac

read -p "Presiona Enter para continuar..."