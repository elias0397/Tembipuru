#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# update_tembipuru.sh - Verifica y realiza actualizaciones de Tembipuru desde GitHub

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

BASE_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

clear
echo -e "${CYAN}=============================================="
echo -e "      🔄 Actualizar Tembipuru CLI Suite"
echo -e "=============================================="${RESET}
echo

# Verificar si está en un repositorio Git
if ! git -C "$BASE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Error: El directorio de Tembipuru no es un repositorio Git válido.${RESET}"
    echo -e "Para usar la actualización automática, clona el repositorio desde GitHub:"
    echo -e "${YELLOW}git clone git@github.com:elias0397/Tembipuru.git${RESET}"
    echo
    read -p "Presiona Enter para volver..."
    exit 1
fi

echo -e "🔍 Buscando actualizaciones en GitHub..."
# Hacer git fetch silencioso para traer los cambios del remoto
if ! git -C "$BASE_DIR" fetch --quiet origin main >/dev/null 2>&1; then
    echo -e "${RED}No se pudo conectar con el repositorio remoto de GitHub.${RESET}"
    echo -e "Por favor, verifica tu conexión a internet o tus credenciales SSH/Git.${RESET}"
    echo
    read -p "Presiona Enter para volver..."
    exit 1
fi

# Obtener rama actual y commits local/remoto
BRANCH=$(git -C "$BASE_DIR" rev-parse --abbrev-ref HEAD)
LOCAL_COMMIT=$(git -C "$BASE_DIR" rev-parse HEAD)
REMOTE_COMMIT=$(git -C "$BASE_DIR" rev-parse "origin/$BRANCH" 2>/dev/null || git -C "$BASE_DIR" rev-parse "origin/main")

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    echo -e "${GREEN}¡Tembipuru ya está actualizado a la última versión!${RESET}"
    echo
    # Mostrar detalles de la versión actual
    LOCAL_DATE=$(git -C "$BASE_DIR" log -1 --format="%cd" --date=short)
    LOCAL_MSG=$(git -C "$BASE_DIR" log -1 --format="%s")
    echo -e "Versión actual: ${CYAN}$LOCAL_DATE (${LOCAL_COMMIT:0:7})${RESET}"
    echo -e "Último cambio:  $LOCAL_MSG"
    echo
    read -p "Presiona Enter para volver..."
    exit 0
fi

# Si hay actualizaciones disponibles
LOCAL_DATE=$(git -C "$BASE_DIR" log -1 --format="%cd" --date=short)
REMOTE_DATE=$(git -C "$BASE_DIR" log -1 --format="%cd" --date=short "$REMOTE_COMMIT")

echo -e "${YELLOW}⚠️ ¡Hay una nueva versión disponible en GitHub!${RESET}"
echo
echo -e "Versión instalada:   ${RED}$LOCAL_DATE (${LOCAL_COMMIT:0:7})${RESET}"
echo -e "Versión disponible:  ${GREEN}$REMOTE_DATE (${REMOTE_COMMIT:0:7})${RESET}"
echo
echo -e "${CYAN}--- Nuevos cambios en esta versión ---${RESET}"
git -C "$BASE_DIR" log "$LOCAL_COMMIT..$REMOTE_COMMIT" --oneline
echo

read -p "¿Deseas actualizar Tembipuru ahora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "\n📥 Descargando e instalando actualizaciones..."
    if git -C "$BASE_DIR" pull origin "$BRANCH" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ ¡Tembipuru se ha actualizado correctamente!${RESET}"
        echo -e "${YELLOW}Por favor, reinicia la herramienta para aplicar los cambios.${RESET}"
    else
        # Si falla por cambios locales sin commit, ofrecer stash
        echo -e "${RED}Error: Tienes cambios locales sin guardar que impiden la actualización.${RESET}"
        read -p "¿Deseas guardar tus cambios en un stash y forzar la actualización? (s/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            git -C "$BASE_DIR" stash >/dev/null 2>&1
            if git -C "$BASE_DIR" pull origin "$BRANCH"; then
                echo -e "${GREEN}✓ ¡Tembipuru se ha actualizado correctamente (se guardó tu stash)!${RESET}"
                echo -e "${YELLOW}Por favor, reinicia la herramienta para aplicar los cambios.${RESET}"
            else
                echo -e "${RED}Error al actualizar incluso con stash. Intenta hacer git pull manualmente.${RESET}"
            fi
        else
            echo -e "${YELLOW}Actualización cancelada para proteger tus archivos locales.${RESET}"
        fi
    fi
else
    echo -e "${YELLOW}Actualización omitida.${RESET}"
fi

echo
read -p "Presiona Enter para continuar..."
