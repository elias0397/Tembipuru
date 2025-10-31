#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# Script: manage_firewall.sh
# Permite gestionar el firewall en Linux (UFW, firewalld o iptables) desde un menú interactivo
# Autor: Elias Araujo (modificado por IA)

set -e

# === DETECTAR BACKEND DISPONIBLE ===
detect_firewall() {
    if command -v ufw &>/dev/null; then
        echo "ufw"
    elif command -v firewall-cmd &>/dev/null; then
        echo "firewalld"
    elif command -v iptables &>/dev/null; then
        echo "iptables"
    else
        echo "none"
    fi
}

FIREWALL=$(detect_firewall)

if [[ "$FIREWALL" == "none" ]]; then
  echo "Ningún gestor de firewall soportado encontrado (ufw, firewalld, iptables). Instala uno primero."
  exit 1
fi

# === FUNCIONES PARA UFW ===
ufw_status() { sudo ufw status verbose; }
ufw_enable() { sudo ufw enable; }
ufw_disable() { sudo ufw disable; }
ufw_allow() { sudo ufw allow "$1"; }
ufw_deny() { sudo ufw deny "$1"; }
ufw_delete() { sudo ufw delete allow "$1"; sudo ufw delete deny "$1"; }

# === FUNCIONES PARA FIREWALLD ===
firewalld_status() { sudo firewall-cmd --state; }
firewalld_enable() { sudo systemctl start firewalld && sudo systemctl enable firewalld; }
firewalld_disable() { sudo systemctl stop firewalld && sudo systemctl disable firewalld; }
firewalld_allow() { sudo firewall-cmd --permanent --add-port="$1"; sudo firewall-cmd --reload; }
firewalld_deny() { sudo firewall-cmd --permanent --remove-port="$1"; sudo firewall-cmd --reload; }
firewalld_delete() { sudo firewall-cmd --permanent --remove-port="$1"; sudo firewall-cmd --reload; }

# === FUNCIONES PARA IPTABLES ===
iptables_status() { sudo iptables -L -v; }
iptables_enable() { sudo systemctl start iptables || echo "(Si ves reglas, iptables ya está activo)"; }
iptables_disable() { sudo iptables -F; }
iptables_allow() { sudo iptables -A INPUT -p tcp --dport "$1" -j ACCEPT; }
iptables_deny() { sudo iptables -A INPUT -p tcp --dport "$1" -j DROP; }
iptables_delete() { sudo iptables -D INPUT -p tcp --dport "$1" -j ACCEPT 2>/dev/null || true; sudo iptables -D INPUT -p tcp --dport "$1" -j DROP 2>/dev/null || true; }

# === MENÚ INTERACTIVO ===
while true; do
    clear
    echo "==== Gestión de Firewall ($FIREWALL) ===="
    echo "1) Ver estado actual"
    echo "2) Activar firewall"
    echo "3) Desactivar firewall"
    echo "4) Permitir un puerto/regla"
    echo "5) Bloquear (negar) un puerto/regla"
    echo "6) Eliminar regla/puerto"
    echo "7) Salir"
    echo
    read -p "Selecciona una opción: " opt
    case $opt in
        1)
            case $FIREWALL in
                ufw) ufw_status;;
                firewalld) firewalld_status;;
                iptables) iptables_status;;
            esac
            ;;
        2)
            case $FIREWALL in
                ufw) ufw_enable;;
                firewalld) firewalld_enable;;
                iptables) iptables_enable;;
            esac
            echo "Firewall activado."
            ;;
        3)
            case $FIREWALL in
                ufw) ufw_disable;;
                firewalld) firewalld_disable;;
                iptables) iptables_disable;;
            esac
            echo "Firewall desactivado."
            ;;
        4)
            read -p "Introduce el puerto o la regla a permitir (Ej: 22/tcp, 443, ssh): " regla
            case $FIREWALL in
                ufw) ufw_allow "$regla";;
                firewalld) firewalld_allow "$regla";;
                iptables) iptables_allow "$regla";;
            esac
            echo "Permiso agregado para $regla."
            ;;
        5)
            read -p "Introduce el puerto a bloquear/denegar (Ej: 80, 23, etc): " regla
            case $FIREWALL in
                ufw) ufw_deny "$regla";;
                firewalld) firewalld_deny "$regla";;
                iptables) iptables_deny "$regla";;
            esac
            echo "Bloqueo/nedo aplicado en $regla."
            ;;
        6)
            read -p "Introduce el puerto o regla a eliminar: " regla
            case $FIREWALL in
                ufw) ufw_delete "$regla";;
                firewalld) firewalld_delete "$regla";;
                iptables) iptables_delete "$regla";;
            esac
            echo "Regla $regla eliminada."
            ;;
        7)
            exit 0
            ;;
        *)
            echo "Opción no válida.";;
    esac
    echo
    read -p "Presiona Enter para continuar..."
done

