#!/bin/bash
# port_scan.sh - Escaneo simple de puertos usando nc o nmap
HOST="127.0.0.1"
PORTS="22,80,443"

if [ $# -ge 1 ]; then
  HOST="$1"
fi
if [ $# -ge 2 ]; then
  PORTS="$2"
fi

IFS=, read -ra PORT_ARR <<< "$PORTS"

echo "Escaneando host: $HOST puertos: $PORTS"

# Cargar helper común
source "$(dirname "$(realpath "$0")")/helpers.sh" || { echo "No se pudo cargar helpers.sh"; exit 1; }

if command -v nc >/dev/null 2>&1; then
  for p in "${PORT_ARR[@]}"; do
    echo -n "Puerto $p: "
    nc -z -w 2 "$HOST" "$p" && echo "OPEN" || echo "CLOSED/filtered"
  done
elif command -v nmap >/dev/null 2>&1; then
  echo "nc no disponible, usando nmap"
  nmap -p "$PORTS" "$HOST"
elif check_and_install nc netcat-openbsd; then
  for p in "${PORT_ARR[@]}"; do
    echo -n "Puerto $p: "
    nc -z -w 2 "$HOST" "$p" && echo "OPEN" || echo "CLOSED/filtered"
  done
elif check_and_install nmap nmap; then
  nmap -p "$PORTS" "$HOST"
else
  echo "Ni 'nc' ni 'nmap' están disponibles y no se instalaron. Abortando."
  exit 1
fi
