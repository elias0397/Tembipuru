#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA

# === CONFIGURACIÓN ===
BASE_DIR="$(dirname "$(realpath "$0")")"
DISK_DIR="$BASE_DIR/.Discos_y_utilidades"

# Mensajes de depuración
echo "BASE_DIR: $BASE_DIR"
echo "DISK_DIR: $DISK_DIR"

# === COLORES ===
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Modo debug: si REMBIPURU_DEBUG=1 entonces mostramos rutas y scripts asociados en los menús
if [ "${REMBIPURU_DEBUG:-0}" = "1" ]; then
    DEBUG=1
else
    DEBUG=0
fi
# === PANTALLA DE PRESENTACIÓN ===
echo -e "${CYAN}"
echo "=============================================="
echo "        🐧 Tembipuru Linux CLI Suite"
echo "=============================================="
echo -e "${YELLOW} Versión BETA - Herramientas para el sistema"
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
    if [ "$DEBUG" -eq 1 ]; then
        echo "Directorio de scripts: $BASE_DIR/.scripts"
        echo "1) Actualizaciones (.scripts/update_system.sh)"
        echo "2) Discos y utilidades (scripts en .Discos_y_utilidades)"
        echo "3) Información del sistema (.scripts/neofetch_info.sh)"
        echo "4) Pruebas y configuraciones de red (scripts en .Pruebas_y_configuraciones_red)"
        echo "5) Gestión de usuarios y grupos (scripts en .Gestion_usuarios_y_grupos)"
        echo "6) Salir"
    else
        echo "1) Actualizaciones"
        echo "2) Discos y utilidades"
        echo "3) Información del sistema"
        echo "4) Pruebas y configuraciones de red"
        echo "5) Gestión de usuarios y grupos"
        echo "6) Salir"
    fi
        echo
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1)
                if [[ -f "$BASE_DIR/.scripts/update_system.sh" ]]; then
                    bash "$BASE_DIR/.scripts/update_system.sh"
                else
                    echo -e "${RED}Script de actualización no encontrado: $BASE_DIR/.scripts/update_system.sh${RESET}"
                    read -p "Presiona Enter..."
                fi
                ;;
            2)
                discos_menu
                ;;  
            3)
                if [[ -f "$BASE_DIR/.scripts/neofetch_info.sh" ]]; then
                    bash "$BASE_DIR/.scripts/neofetch_info.sh"
                else
                    echo -e "${RED}No se encontró $BASE_DIR/.scripts/neofetch_info.sh${RESET}"
                    read -p "Presiona Enter para volver al menú..."
                fi
                ;;
            4)
                red_menu
                ;;
            5)
                if [[ -f "$BASE_DIR/.Gestion_usuarios_y_grupos/manage_users_groups.sh" ]]; then
                    bash "$BASE_DIR/.Gestion_usuarios_y_grupos/manage_users_groups.sh"
                else
                    echo -e "${RED}No se encontró $BASE_DIR/.Gestion_usuarios_y_grupos/manage_users_groups.sh${RESET}"
                    read -p "Presiona Enter para volver al menú..."
                fi
                ;;
            6)
                echo "Saliendo de Tembipuru Linux..."
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
        if [ "$DEBUG" -eq 1 ]; then
            echo "Directorio: $DISK_DIR"
            echo "1) Listar discos montados (list_disks.sh)"
            echo "2) Ver espacio en disco (disk_space.sh)"
            echo "3) Reparar Formato de disco (reparar_formato.sh)"
            echo "4) Formatear disco (Peligroso) (formatear_disco.sh)"
            echo "5) Volver"
        else
            echo "1) Listar discos montados"
            echo "2) Ver espacio en disco"
            echo "3) Reparar Formato de disco"
            echo "4) Formatear disco (Peligroso)"
            echo "5) Volver"
        fi
        echo
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1)
                if [[ -f "$DISK_DIR/list_disks.sh" ]]; then
                    bash "$DISK_DIR/list_disks.sh"
                else
                    lsblk -f
                fi
                ;;
            2)
                if [[ -f "$DISK_DIR/disk_space.sh" ]]; then
                    bash "$DISK_DIR/disk_space.sh"
                else
                    df -h
                fi
                ;;
            3)
                if [[ -f "$DISK_DIR/reparar_formato.sh" ]]; then
                    bash "$DISK_DIR/reparar_formato.sh"
                else
                    echo -e "${RED}No se encontró el script reparar_formato.sh${RESET}"
                fi
                ;;
            4)
                if [[ -f "$DISK_DIR/formatear_disco.sh" ]]; then
                    bash "$DISK_DIR/formatear_disco.sh"
                else
                    echo -e "${RED}No se encontró el script formatear_disco.sh${RESET}"
                fi
                ;;
            5)
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

# === SUBMENÚ: PRUEBAS Y CONFIGURACIONES DE RED ===
red_menu() {
    PRUEBAS_DIR="$BASE_DIR/.Pruebas_y_configuraciones_red"
    while true; do
        clear
        echo -e "${CYAN}=== Pruebas y configuraciones de red ===${RESET}"
        if [ "$DEBUG" -eq 1 ]; then
            echo "Directorio: $PRUEBAS_DIR"
            echo "1) Estado de servicios de red (network_services.sh)"
            echo "2) Ejecutar prueba de ping (test_ping.sh)"
            echo "3) Consulta DNS (dns_lookup.sh)"
            echo "4) Traceroute (traceroute_test.sh)"
            echo "5) Escaneo de puertos Nmap (port_scan.sh)"
            echo "6) Verificar puertos en escucha Netstat (netstat.sh)"
            echo "7) Estado del Firewall (firewall_status.sh)"
            echo "8) Gestionar Firewall (manage_firewall.sh)"
            echo "9) Volver"
        else
            echo "1) Estado de servicios de red"
            echo "2) Ejecutar prueba de ping"
            echo "3) Consulta DNS"
            echo "4) Traceroute"
            echo "5) Escaneo de puertos Nmap"
            echo "6) Verificar puertos en escucha Netstat"
            echo "7) Estado del Firewall"
            echo "8) Gestionar Firewall"
            echo "9) Volver"
        fi
        echo
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1)
                if [[ -f "$PRUEBAS_DIR/network_services.sh" ]]; then
                    bash "$PRUEBAS_DIR/network_services.sh"
                else
                    echo -e "${RED}No se encontró network_services.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            2)
                if [[ -f "$PRUEBAS_DIR/test_ping.sh" ]]; then
                    bash "$PRUEBAS_DIR/test_ping.sh"
                else
                    echo -e "${RED}No se encontró test_ping.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            3)
                if [[ -f "$PRUEBAS_DIR/dns_lookup.sh" ]]; then
                    bash "$PRUEBAS_DIR/dns_lookup.sh"
                else
                    echo -e "${RED}No se encontró dns_lookup.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            4)
                if [[ -f "$PRUEBAS_DIR/traceroute_test.sh" ]]; then
                    bash "$PRUEBAS_DIR/traceroute_test.sh"
                else
                    echo -e "${RED}No se encontró traceroute_test.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            5)
                if [[ -f "$PRUEBAS_DIR/port_scan.sh" ]]; then
                    bash "$PRUEBAS_DIR/port_scan.sh"
                else
                    echo -e "${RED}No se encontró port_scan.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            6)
                if [[ -f "$PRUEBAS_DIR/netstat.sh" ]]; then
                    bash "$PRUEBAS_DIR/netstat.sh"
                else
                    echo -e "${YELLOW}Verificando puertos abiertos (netstat)...${RESET}"
                    if ! command -v netstat &> /dev/null; then
                        echo -e "${RED}netstat no está instalado. Instalando net-tools...${RESET}"
                        sudo apt update && sudo apt install -y net-tools
                    fi
                    sudo netstat -tuln
                    read -p "Presiona Enter para continuar..."
                fi
                ;;
            7)
                if [[ -f "$PRUEBAS_DIR/firewall_status.sh" ]]; then
                    bash "$PRUEBAS_DIR/firewall_status.sh"
                else
                    echo -e "${RED}No se encontró firewall_status.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            8)
                if [[ -f "$PRUEBAS_DIR/manage_firewall.sh" ]]; then
                    bash "$PRUEBAS_DIR/manage_firewall.sh"
                else
                    echo -e "${RED}No se encontró manage_firewall.sh en $PRUEBAS_DIR${RESET}"
                fi
                ;;
            9)
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
k
