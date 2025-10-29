#!/bin/bash
# network_test_suite.sh - Ejecuta varias pruebas de red en serie y genera un resumen
BASE_DIR="$(dirname "$(realpath "$0")")"
REPORT="${BASE_DIR}/network_test_report_$(date +%Y%m%d_%H%M%S).txt"

HOST="8.8.8.8"
DOMAIN="example.com"
PORTS="22,80,443"

if [ $# -ge 1 ]; then
  HOST="$1"
fi
if [ $# -ge 2 ]; then
  DOMAIN="$2"
fi
if [ $# -ge 3 ]; then
  PORTS="$3"
fi

echo "Network Test Suite - Inicio: $(date)" | tee "$REPORT"

echo "\n1) Ping a $HOST" | tee -a "$REPORT"
ping -c 4 "$HOST" | tee -a "$REPORT"

# Cargar helper común
source "$(dirname "$(realpath "$0")")/helpers.sh" || { echo "No se pudo cargar helpers.sh"; exit 1; }

echo "\n2) Traceroute a $HOST" | tee -a "$REPORT"
if command -v traceroute >/dev/null 2>&1; then
  traceroute -m 30 "$HOST" | tee -a "$REPORT"
elif command -v tracepath >/dev/null 2>&1; then
  tracepath "$HOST" | tee -a "$REPORT"
elif check_and_install traceroute traceroute; then
  traceroute -m 30 "$HOST" | tee -a "$REPORT"
else
  echo "(traceroute/tracepath no instalado y no se instaló)" | tee -a "$REPORT"
fi

echo "\n3) Resolución DNS de $DOMAIN" | tee -a "$REPORT"
if command -v dig >/dev/null 2>&1; then
  dig +short "$DOMAIN" | tee -a "$REPORT"
elif command -v host >/dev/null 2>&1; then
  host "$DOMAIN" | tee -a "$REPORT"
elif check_and_install dig dnsutils; then
  dig +short "$DOMAIN" | tee -a "$REPORT"
else
  echo "(dig/host no instalado y no se instaló)" | tee -a "$REPORT"
fi

echo "\n4) Escaneo de puertos $PORTS en localhost" | tee -a "$REPORT"
if command -v nc >/dev/null 2>&1; then
  IFS=, read -ra PARR <<< "$PORTS"
  for p in "${PARR[@]}"; do
    echo -n "Puerto $p: " | tee -a "$REPORT"
    nc -z -w 2 127.0.0.1 "$p" && echo "OPEN" | tee -a "$REPORT" || echo "CLOSED/filtered" | tee -a "$REPORT"
  done
elif command -v nmap >/dev/null 2>&1; then
  nmap -p "$PORTS" 127.0.0.1 | tee -a "$REPORT"
elif check_and_install nc netcat-openbsd; then
  IFS=, read -ra PARR <<< "$PORTS"
  for p in "${PARR[@]}"; do
    echo -n "Puerto $p: " | tee -a "$REPORT"
    nc -z -w 2 127.0.0.1 "$p" && echo "OPEN" | tee -a "$REPORT" || echo "CLOSED/filtered" | tee -a "$REPORT"
  done
elif check_and_install nmap nmap; then
  nmap -p "$PORTS" 127.0.0.1 | tee -a "$REPORT"
else
  echo "(nc/nmap no instalado y no se instaló)" | tee -a "$REPORT"
fi

echo "\nNetwork Test Suite - Fin: $(date)" | tee -a "$REPORT"

echo "\nInforme guardado en: $REPORT"
