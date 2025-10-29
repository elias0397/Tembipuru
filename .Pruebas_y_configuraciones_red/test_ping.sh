#!/bin/bash
# test_ping.sh - Prueba segura de conectividad mediante ping
# No modifica la configuración del sistema; solo realiza pruebas de conectividad.

TARGET="8.8.8.8"
COUNT=4

if [ $# -ge 1 ]; then
  TARGET="$1"
fi

if [ $# -ge 2 ]; then
  COUNT="$2"
fi

echo "Prueba de ping a: $TARGET (conteo: $COUNT)"
echo "Presione Ctrl+C para cancelar"

ping -c "$COUNT" "$TARGET"

# Salida amigable
if [ $? -eq 0 ]; then
  echo "\nResultado: Conectividad OK"
else
  echo "\nResultado: No se pudo alcanzar el destino"
fi
