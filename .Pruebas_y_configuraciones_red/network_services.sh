#!/bin/bash
# network_services.sh - Muestra el estado de los servicios de red

echo -e "\e[33mEstado de servicios de red:\e[0m"
systemctl status NetworkManager
echo -e "\n\e[33mEstado de interfaces:\e[0m"
ip link show

read -p "Presiona Enter para continuar..."