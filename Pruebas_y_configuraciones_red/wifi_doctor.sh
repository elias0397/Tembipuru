#!/bin/bash
# ==============================================================================
# 🩺 WiFi Doctor - Analizador y Optimizador de Redes Inalámbricas
# ==============================================================================

# Colores y estilos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color
BOLD='\033[1m'

# ==============================================================================
# 1. Gestión de Dependencias Automática
# ==============================================================================
check_dependencies() {
    echo -e "${CYAN}${BOLD}🔍 Verificando dependencias...${NC}"
    if ! command -v nmcli &> /dev/null; then
        echo -e "${YELLOW}⚠️ 'nmcli' no está instalado. Intentando instalación automática...${NC}"
        
        if command -v pacman &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: pacman (Arch/CachyOS)${NC}"
            sudo pacman -Sy --noconfirm networkmanager
        elif command -v apt &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: apt (Debian/Ubuntu)${NC}"
            sudo apt update && sudo apt install -y network-manager
        elif command -v dnf &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: dnf (Fedora/RHEL)${NC}"
            sudo dnf install -y NetworkManager
        else
            echo -e "${RED}❌ No se pudo detectar un gestor de paquetes soportado.${NC}"
            echo -e "Por favor, instala 'networkmanager' manualmente."
            exit 1
        fi
        
        # Validar instalación
        if ! command -v nmcli &> /dev/null; then
            echo -e "${RED}❌ Falló la instalación de 'nmcli'. Saliendo.${NC}"
            exit 1
        else
            echo -e "${GREEN}✅ 'nmcli' instalado correctamente.${NC}"
        fi
    else
        echo -e "${GREEN}✅ Dependencias satisfechas (nmcli).${NC}"
    fi
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 2. Escaneo inicial
# ==============================================================================
scan_networks() {
    echo -e "${CYAN}${BOLD}📡 Escaneando redes WiFi cercanas...${NC}"
    nmcli dev wifi rescan &> /dev/null
    sleep 3
    echo -e "${GREEN}✅ Escaneo completado.${NC}"
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 3. Identificación de red actual y Análisis Básico
# ==============================================================================
analyze_wifi() {
    echo -e "${CYAN}${BOLD}📊 Analizando conexión actual...${NC}"
    
    CURRENT_WIFI_LINE=$(nmcli -t -f IN-USE,SSID,CHAN,SIGNAL,FREQ dev wifi | grep "^*")
    
    if [ -z "$CURRENT_WIFI_LINE" ]; then
        echo -e "${RED}❌ No estás conectado a ninguna red WiFi.${NC}"
        exit 1
    fi
    
    # Parsear los campos
    SSID=$(echo "$CURRENT_WIFI_LINE" | cut -d':' -f2)
    CHAN=$(echo "$CURRENT_WIFI_LINE" | cut -d':' -f3)
    SIGNAL=$(echo "$CURRENT_WIFI_LINE" | cut -d':' -f4)
    FREQ=$(echo "$CURRENT_WIFI_LINE" | cut -d':' -f5 | tr -d ' MHz')
    
    echo -e "🌐 ${BOLD}Red Actual:${NC} $SSID"
    echo -e "📻 ${BOLD}Frecuencia:${NC} $FREQ MHz"
    echo -e "📺 ${BOLD}Canal en uso:${NC} $CHAN"
    
    # 4. Diagnóstico de Señal
    echo -n -e "📶 ${BOLD}Fuerza de la Señal (${SIGNAL}%):${NC} "
    if [ "$SIGNAL" -ge 80 ]; then
        echo -e "${GREEN}Excelente (Conexión óptima) ✅${NC}"
    elif [ "$SIGNAL" -ge 60 ]; then
        echo -e "${YELLOW}Aceptable (Navegación estable) ⚠️${NC}"
    elif [ "$SIGNAL" -ge 40 ]; then
        echo -e "${RED}Débil (Sugerencia: Acércate al router) ⚠️${NC}"
    else
        echo -e "${RED}${BOLD}Crítica (Punto ciego) ❌${NC}"
    fi
    
    # 5. Diagnóstico de Saturación
    SAME_CHAN_COUNT=$(nmcli -t -f CHAN dev wifi | grep -w "^$CHAN" | wc -l)
    let "NEIGHBORS = SAME_CHAN_COUNT - 1"
    
    if [ "$NEIGHBORS" -lt 0 ]; then NEIGHBORS=0; fi
    
    echo -n -e "🚦 ${BOLD}Saturación del Canal ($CHAN):${NC} "
    if [ "$NEIGHBORS" -eq 0 ]; then
        echo -e "${GREEN}Libre (0 redes vecinas) ✅${NC}"
    elif [ "$NEIGHBORS" -le 2 ]; then
        echo -e "${YELLOW}Tráfico ligero ($NEIGHBORS redes vecinas) ⚠️${NC}"
    else
        echo -e "${RED}Canal saturado ($NEIGHBORS redes vecinas) ❌${NC}"
    fi
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 6. Diagnóstico de Latencia (Ping al Router)
# ==============================================================================
check_latency() {
    echo -e "${CYAN}${BOLD}⏱️ Realizando prueba de latencia...${NC}"
    
    GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n 1)
    GLOBAL_LATENCY=999 # Valor por defecto alto en caso de fallo
    
    if [ -z "$GATEWAY" ]; then
        echo -e "${YELLOW}⚠️ No se pudo detectar la IP del router para la prueba de ping.${NC}"
    else
        LATENCY=$(ping -c 5 "$GATEWAY" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
        
        if [ -z "$LATENCY" ]; then
            echo -e "${RED}❌ Falló la comunicación con el router ($GATEWAY).${NC}"
        else
            echo -e "   - Router detectado: $GATEWAY"
            echo -e "   - Latencia promedio: ${BOLD}${LATENCY} ms${NC}"
            
            LAT_VAL=${LATENCY%.*}
            
            if [ -n "$LAT_VAL" ]; then
                GLOBAL_LATENCY=$LAT_VAL
                if [ "$LAT_VAL" -lt 15 ]; then
                    echo -e "   - Calidad: ${GREEN}Excelente (Muy estable) ✅${NC}"
                elif [ "$LAT_VAL" -lt 30 ]; then
                    echo -e "   - Calidad: ${GREEN}Buena (Estable) 👍${NC}"
                else
                    echo -e "   - Calidad: ${RED}Alta latencia (Posible interferencia física o espectral) ⚠️${NC}"
                fi
            fi
        fi
    fi
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 7. Recomendación de Optimización Inteligente
# ==============================================================================
optimize_wifi() {
    if [ "$NEIGHBORS" -ge 1 ]; then
        echo -e "${CYAN}${BOLD}💡 Evaluando alternativas de optimización...${NC}"
        
        # NUEVA REGLA: Si la latencia es excelente, no recomendar cambios aunque haya vecinos
        if [ "$GLOBAL_LATENCY" -lt 15 ]; then
            echo -e "${GREEN}✅ Aunque hay $NEIGHBORS red(es) vecina(s), tu latencia actual es excelente (${GLOBAL_LATENCY} ms).${NC}"
            echo -e "${GREEN}   👉 No se recomienda cambiar el canal ya que no hay interferencia activa afectando el rendimiento.${NC}"
            echo -e "${CYAN}------------------------------------------------------------${NC}"
            return 0
        fi

        # Si hay vecinos Y la latencia es mala (o falló), procedemos a recomendar
        CHANNEL_COUNTS=$(nmcli -t -f CHAN dev wifi | awk -F':' '/^[0-9]+/ {count[$1]++} END {for (c in count) print c ":" count[c]}' | sort -n -t ':' -k1,1)
        
        # --- Banda 2.4 GHz ---
        if [[ "$FREQ" == 24* ]]; then
            echo -e "${BLUE}Banda detectada: 2.4 GHz${NC}"
            COUNT_1=0; COUNT_6=0; COUNT_11=0
            
            for CH_DATA in $CHANNEL_COUNTS; do
                CH=$(echo "$CH_DATA" | cut -d':' -f1)
                CNT=$(echo "$CH_DATA" | cut -d':' -f2)
                if [ "$CH" -eq 1 ]; then COUNT_1=$CNT; fi
                if [ "$CH" -eq 6 ]; then COUNT_6=$CNT; fi
                if [ "$CH" -eq 11 ]; then COUNT_11=$CNT; fi
            done
            
            echo -e "   - Canal 1:  $COUNT_1 redes"
            echo -e "   - Canal 6:  $COUNT_6 redes"
            echo -e "   - Canal 11: $COUNT_11 redes"
            
            EVAL_1=$COUNT_1; EVAL_6=$COUNT_6; EVAL_11=$COUNT_11
            if [ "$CHAN" -eq 1 ]; then EVAL_1=999; fi
            if [ "$CHAN" -eq 6 ]; then EVAL_6=999; fi
            if [ "$CHAN" -eq 11 ]; then EVAL_11=999; fi
            
            MIN_EVAL=$EVAL_1; BEST_CHAN=1; REAL_COUNT=$COUNT_1
            if [ "$EVAL_6" -lt "$MIN_EVAL" ]; then MIN_EVAL=$EVAL_6; BEST_CHAN=6; REAL_COUNT=$COUNT_6; fi
            if [ "$EVAL_11" -lt "$MIN_EVAL" ]; then MIN_EVAL=$EVAL_11; BEST_CHAN=11; REAL_COUNT=$COUNT_11; fi
            
            if [ "$MIN_EVAL" -eq 999 ]; then
                echo -e "\n${YELLOW}⚠️ No se encontraron alternativas viables en canales principales.${NC}"
            else
                echo -e "\n${GREEN}💡 ${BOLD}Recomendación:${NC} Cambia tu router al ${BOLD}Canal $BEST_CHAN${NC} (el menos congestionado con $REAL_COUNT redes vecinas)."
            fi
            
        # --- Banda 5.0 GHz y 6.0 GHz ---
        elif [[ "$FREQ" == 5* ]] || [[ "$FREQ" == 6* ]]; then
            if [[ "$FREQ" == 5* ]]; then echo -e "${BLUE}Banda detectada: 5.0 GHz${NC}"; else echo -e "${BLUE}Banda detectada: 6.0 GHz (WiFi 6E/7)${NC}"; fi
            echo -e "   ${BOLD}Redes por canal detectadas en el entorno:${NC}"
            
            BEST_CHAN=""; MIN_COUNT=999
            
            for CH_DATA in $CHANNEL_COUNTS; do
                CH=$(echo "$CH_DATA" | cut -d':' -f1)
                CNT=$(echo "$CH_DATA" | cut -d':' -f2)
                
                if [ "$CH" -ge 36 ]; then
                    echo -e "   - Canal $CH: $CNT redes"
                    if [ "$CH" == "$CHAN" ]; then continue; fi
                    if [ "$CNT" -lt "$MIN_COUNT" ]; then MIN_COUNT=$CNT; BEST_CHAN=$CH; fi
                fi
            done
            
            if [ -z "$BEST_CHAN" ]; then
                 echo -e "\n${YELLOW}⚠️ No se detectaron otros canales libres en el entorno. Evalúa un canal estándar manualmente.${NC}"
            else
                 echo -e "\n${GREEN}💡 ${BOLD}Recomendación:${NC} Cambia tu router al ${BOLD}Canal $BEST_CHAN${NC} (el alternativo menos congestionado con $MIN_COUNT redes vecinas)."
            fi
        fi
        echo -e "${CYAN}------------------------------------------------------------${NC}"
    fi
}

# ==============================================================================
# Ejecución principal
# ==============================================================================
echo -e "${BOLD}============================================================${NC}"
echo -e "${CYAN}${BOLD}                 🩺 WiFi Doctor 🩺                 ${NC}"
echo -e "${BOLD}============================================================${NC}"
check_dependencies
scan_networks
analyze_wifi
check_latency
optimize_wifi
echo -e "${BOLD}============================================================${NC}"