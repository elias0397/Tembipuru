#!/bin/bash
# ==============================================================================
# 🔌 Serial Manager - Gestor de Conexiones por Puerto Serie
# ==============================================================================

# Colores y estilos ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color
BOLD='\033[1m'

# ==============================================================================
# 1. Instalación de dependencias
# ==============================================================================
instalar_dependencias() {
    echo -e "${CYAN}${BOLD}🔍 Verificando dependencias (screen)...${NC}"
    if ! command -v screen &> /dev/null; then
        echo -e "${YELLOW}⚠️ 'screen' no está instalado. Intentando instalación automática...${NC}"
        
        if command -v pacman &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: pacman (Arch/CachyOS)${NC}"
            sudo pacman -Sy --noconfirm screen
        elif command -v apt &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: apt (Debian/Ubuntu)${NC}"
            sudo apt update && sudo apt install -y screen
        elif command -v dnf &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: dnf (Fedora/RHEL)${NC}"
            sudo dnf install -y screen
        elif command -v yum &> /dev/null; then
            echo -e "${BLUE}📦 Gestor detectado: yum (CentOS/RHEL antiguos)${NC}"
            sudo yum install -y screen
        else
            echo -e "${RED}❌ No se pudo detectar un gestor de paquetes soportado.${NC}"
            echo -e "Por favor, instala 'screen' manualmente."
            echo
            read -p "Presiona Enter para salir..."
            exit 1
        fi
        
        # Validar instalación
        if ! command -v screen &> /dev/null; then
            echo -e "${RED}❌ Falló la instalación de 'screen'. Saliendo.${NC}"
            echo
            read -p "Presiona Enter para salir..."
            exit 1
        else
            echo -e "${GREEN}✅ 'screen' instalado correctamente.${NC}"
        fi
    else
        echo -e "${GREEN}✅ Dependencias satisfechas (screen).${NC}"
    fi
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 2. Listar y seleccionar puertos
# ==============================================================================
listar_puertos() {
    echo -e "${CYAN}${BOLD}🔎 Buscando puertos serie disponibles...${NC}"
    
    # Buscar dispositivos ttyUSB y ttyACM
    puertos=($(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null))
    
    if [ ${#puertos[@]} -eq 0 ]; then
        echo -e "${RED}❌ No se detectó ningún puerto serie (/dev/ttyUSB* o /dev/ttyACM*).${NC}"
        echo -e "${YELLOW}Verifica que el cable consola esté conectado correctamente.${NC}"
        echo
        read -p "Presiona Enter para volver..."
        exit 1
    fi
    
    echo -e "${GREEN}✅ Puertos detectados.${NC} Selecciona el puerto al que deseas conectarte:\n"
    
    PS3="👉 Ingresa el número del puerto: "
    select PUERTO_SELECCIONADO in "${puertos[@]}"; do
        if [[ -n "$PUERTO_SELECCIONADO" ]]; then
            echo -e "\n${BLUE}🔌 Puerto seleccionado: ${BOLD}$PUERTO_SELECCIONADO${NC}"
            break
        else
            echo -e "${RED}⚠️ Selección inválida, por favor intenta de nuevo.${NC}"
        fi
    done
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 3. Validación de permisos
# ==============================================================================
validar_permisos() {
    echo -e "${CYAN}${BOLD}🔐 Verificando permisos de acceso al puerto...${NC}"
    
    # Obtener el grupo propietario del dispositivo (usualmente dialout o uucp)
    GRUPO_PUERTO=$(stat -c "%G" "$PUERTO_SELECCIONADO" 2>/dev/null)
    
    # Verificar si el usuario actual tiene acceso de lectura y escritura al puerto
    if [ ! -r "$PUERTO_SELECCIONADO" ] || [ ! -w "$PUERTO_SELECCIONADO" ]; then
        echo -e "${RED}⚠️ No tienes permisos de lectura/escritura en $PUERTO_SELECCIONADO.${NC}"
        echo -e "${YELLOW}💡 Para solucionarlo de forma permanente, debes agregarte al grupo '$GRUPO_PUERTO'. Ejecuta:${NC}"
        echo -e "${BOLD}   sudo usermod -a -G $GRUPO_PUERTO \$USER${NC}"
        echo -e "${YELLOW}   (Luego tendrás que cerrar sesión y volver a entrar)${NC}\n"
        
        # Opcionalmente continuar usando sudo para esta sesión
        echo -e "${CYAN}Por ahora, intentaremos ejecutar la conexión con privilegios de superusuario (sudo).${NC}"
        USE_SUDO="sudo "
    else
        echo -e "${GREEN}✅ Permisos correctos.${NC}"
        USE_SUDO=""
    fi
    echo -e "${CYAN}------------------------------------------------------------${NC}"
}

# ==============================================================================
# 4. Configurar y Conectar
# ==============================================================================
conectar() {
    echo -e "${CYAN}${BOLD}⚙️ Configuración de la conexión...${NC}"
    echo "Selecciona el modo de configuración:"
    
    opciones_config=("Sophos (9600 8N1)" "Fortinet (9600 8N1)" "Manual (Ingresar Baudrate)")
    PS3="👉 Selecciona una opción: "
    
    select opt in "${opciones_config[@]}"; do
        case $opt in
            "Sophos (9600 8N1)")
                BAUDRATE=9600
                break
                ;;
            "Fortinet (9600 8N1)")
                BAUDRATE=9600
                break
                ;;
            "Manual (Ingresar Baudrate)")
                read -p "Ingresa el baudrate (ej. 9600, 115200): " BAUDRATE
                # Validar que sea un número
                if ! [[ "$BAUDRATE" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}❌ Baudrate inválido. Usando 9600 por defecto.${NC}"
                    BAUDRATE=9600
                fi
                break
                ;;
            *) echo -e "${RED}⚠️ Opción inválida.${NC}";;
        esac
    done
    
    echo -e "\n${GREEN}🚀 Iniciando conexión en $PUERTO_SELECCIONADO a $BAUDRATE baudios...${NC}"
    echo -e "${YELLOW}💡 Consejo: Para salir de 'screen', presiona Ctrl+A y luego escribe :quit (o \ ).${NC}"
    echo -e "${CYAN}------------------------------------------------------------${NC}"
    sleep 2
    
    # Ejecutar la conexión
    $USE_SUDO screen "$PUERTO_SELECCIONADO" "$BAUDRATE"
}

# ==============================================================================
# Ejecución principal
# ==============================================================================
echo -e "${BOLD}============================================================${NC}"
echo -e "${CYAN}${BOLD}               🔌 Serial Manager 🔌                ${NC}"
echo -e "${BOLD}============================================================${NC}"

instalar_dependencias
listar_puertos
validar_permisos
conectar
