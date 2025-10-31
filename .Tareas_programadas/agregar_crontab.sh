#!/bin/bash

echo "==== Añadir nueva tarea programada (crontab) ===="
echo "¿A qué crontab deseas agregar la tarea?"
echo "1) Al tuyo ($USER)"
echo "2) Al de root (requiere sudo)"
read -p "Opción [1/2]: " op

echo
if [[ "$op" == "2" ]]; then
    CRONCMD='sudo crontab'
    USUARIO="root"
else
    CRONCMD='crontab'
    USUARIO="$USER"
fi

echo "Puedes programar cualquier comando, script, binario, comando encadenado, etc., igual que lo harías en una terminal."
echo "Formato: MIN HORA DIA_MES MES DIA_SEMANA COMANDO"
echo
# Ejemplos claros
echo "Ejemplos de líneas válidas:"
echo "0 3 * * * /home/usuario/backup.sh              # Ejecuta un script todos los días a las 3:00"
echo "30 2 * * 1 tar -czf /backup/lunes.tgz /home/usuario/     # Backup cada lunes 2:30 am"
echo "15 12 * * * echo '¡Es mediodía!' >> ~/mediodia.log      # Mensaje diario al log a las 12:15"
echo "0 4 * * * /usr/bin/python3 /home/usuario/backup.py       # Ejecuta un script de Python"
echo "* * * * * touch /tmp/prueba-cron.txt                    # Crea/actualiza un archivo cada minuto"
echo
read -p "Introduce la nueva línea de tarea crontab: " linea
echo
read -p "¿Agregar esta línea al crontab de $USUARIO? (s/n): " ok
if [[ "$ok" =~ ^[sS]$ ]]; then
    $CRONCMD -l 2>/dev/null | { cat; echo "$linea"; } | $CRONCMD -
    echo "Línea agregada al crontab de $USUARIO."
else
    echo "Cancelado."
fi
echo
