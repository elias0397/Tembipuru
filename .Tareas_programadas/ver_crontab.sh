#!/bin/bash

echo "==== Visualizar tareas programadas (crontab) ===="
echo "¿Qué crontab deseas ver?"
echo "1) El tuyo ($USER)"
echo "2) El de root (tareas administradas por sudo)"
read -p "Opción [1/2]: " op
if [[ "$op" == "2" ]]; then
    sudo crontab -l 2>/dev/null || echo "No hay tareas programadas para root."
else
    crontab -l 2>/dev/null || echo "No hay tareas programadas para este usuario."
fi
echo
