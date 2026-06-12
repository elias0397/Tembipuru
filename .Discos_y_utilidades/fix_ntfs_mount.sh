#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# fix_ntfs_mount.sh - Configura el sistema para evitar el error de montaje NTFS en udisks2

GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

clear
echo -e "${CYAN}====================================================${RESET}"
echo -e "${CYAN}🔧 Solucionar Error de Montaje NTFS (udisks2/Kernel)${RESET}"
echo -e "${CYAN}====================================================${RESET}"
echo -e "Este asistente configura tu sistema para usar el controlador ${YELLOW}ntfs-3g${RESET}"
echo -e "en lugar del estricto controlador del kernel ${RED}ntfs3${RESET}, solucionando el"
echo -e "error 'wrong fs type, bad option, bad superblock' al montar discos NTFS."
echo

echo "Selecciona una opción:"
echo "1) Configurar udisks2 para preferir ntfs-3g (Recomendado)"
echo "2) Añadir ntfs3 a la lista negra (blacklist) del kernel"
echo "3) Revertir cambios (Restaurar configuración predeterminada)"
echo "4) Volver"
echo
read -p "Opción (1-4): " opcion

case $opcion in
    1)
        echo -e "\n⚙️ Configurando udisks2..."
        # Asegurar que existe el directorio
        sudo mkdir -p /etc/udisks2
        
        # Copiar plantilla si no existe
        if [ ! -f /etc/udisks2/mount_options.conf ]; then
            if [ -f /etc/udisks2/mount_options.conf.example ]; then
                sudo cp /etc/udisks2/mount_options.conf.example /etc/udisks2/mount_options.conf
            else
                # Crear archivo básico si no existe la plantilla
                echo -e "[defaults]\nntfs_drivers=ntfs" | sudo tee /etc/udisks2/mount_options.conf > /dev/null
            fi
        fi

        # Configurar ntfs_drivers=ntfs en la sección [defaults]
        if grep -q "ntfs_drivers=" /etc/udisks2/mount_options.conf; then
            sudo sed -i 's/ntfs_drivers=.*/ntfs_drivers=ntfs/' /etc/udisks2/mount_options.conf
        else
            # Si no existe, añadir bajo [defaults]
            sudo sed -i '/\[defaults\]/a ntfs_drivers=ntfs' /etc/udisks2/mount_options.conf
        fi

        echo -e "🔄 Reiniciando servicio udisks2..."
        sudo systemctl restart udisks2
        echo -e "${GREEN}✓ Configuración de udisks2 completada con éxito.${RESET}"
        ;;
    2)
        echo -e "\n⚙️ Bloqueando el módulo ntfs3 del kernel..."
        echo "blacklist ntfs3" | sudo tee /etc/modprobe.d/blacklist-ntfs3.conf > /dev/null
        echo -e "${GREEN}✓ Módulo ntfs3 añadido a la lista negra.${RESET}"
        echo -e "${YELLOW}Nota: Debes reiniciar el sistema para aplicar este cambio.${RESET}"
        ;;
    3)
        echo -e "\n⚙️ Revirtiendo cambios..."
        # Revertir udisks2
        if [ -f /etc/udisks2/mount_options.conf ]; then
            sudo sed -i 's/ntfs_drivers=ntfs/# ntfs_drivers=ntfs/' /etc/udisks2/mount_options.conf
            echo -e "✓ Configuración de udisks2 restablecida."
            sudo systemctl restart udisks2
        fi
        # Revertir blacklist
        if [ -f /etc/modprobe.d/blacklist-ntfs3.conf ]; then
            sudo rm -f /etc/modprobe.d/blacklist-ntfs3.conf
            echo -e "✓ Lista negra de ntfs3 eliminada."
            echo -e "${YELLOW}Nota: Reinicia el sistema para volver a cargar el módulo ntfs3.${RESET}"
        fi
        echo -e "${GREEN}✓ Reversión completada.${RESET}"
        ;;
    4)
        exit 0
        ;;
    *)
        echo -e "${RED}Opción inválida.${RESET}"
        sleep 1
        ;;
esac

read -p "Presiona Enter para continuar..."
