#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# Colores
GREEN="\e[32m"
CYAN="\e[36m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Función principal de formateo
formatear_disco() {
    clear
    echo -e "${RED}⚠️  ADVERTENCIA - FORMATEO DE DISCO ⚠️${RESET}"
    echo -e "${RED}==================================${RESET}"
    echo -e "${YELLOW}Esta operación ELIMINARÁ PERMANENTEMENTE todos los datos del disco seleccionado.${RESET}"
    echo -e "${YELLOW}No hay forma de recuperar los datos después del formateo.${RESET}"
    echo
    
    # Mostrar información de discos
    echo -e "${CYAN}Discos disponibles:${RESET}"
    lsblk -f
    echo
    
    # Primera confirmación
    read -p "¿Estás seguro que deseas continuar? (escriba 'SI' en mayúsculas): " confirm
    if [ "$confirm" != "SI" ]; then
        echo -e "${GREEN}Operación cancelada.${RESET}"
        sleep 2
        return
    fi
    
    # Solicitar dispositivo
    echo
    read -p "Ingrese el nombre exacto del dispositivo a formatear (ejemplo: sdb1): " device
    if [ ! -b "/dev/$device" ]; then
        echo -e "${RED}Error: El dispositivo /dev/$device no existe o no es válido.${RESET}"
        sleep 2
        return
    fi
    
    # Mostrar información específica del dispositivo
    echo -e "\n${CYAN}Información del dispositivo seleccionado:${RESET}"
    lsblk -f "/dev/$device"
    echo
    
    # Segunda confirmación con período de espera
    echo -e "${RED}ÚLTIMA ADVERTENCIA:${RESET}"
    echo "Se formateará el dispositivo: /dev/$device"
    echo -e "${YELLOW}Esperando 10 segundos para reflexionar...${RESET}"
    for i in {10..1}; do
        echo -n "$i... "
        sleep 1
    done
    echo
    
    # Confirmación final con nombre del dispositivo
    read -p "Para confirmar, escriba el nombre exacto del dispositivo nuevamente: " confirm_device
    if [ "$device" != "$confirm_device" ]; then
        echo -e "${RED}Los nombres no coinciden. Operación cancelada.${RESET}"
        sleep 2
        return
    fi
    
    # Selección del sistema de archivos
    echo -e "\n${CYAN}Seleccione el sistema de archivos:${RESET}"
    echo "=== Sistemas de archivos comunes ==="
    echo "1) ext4 (Sistema estándar para Linux)"
    echo "2) ntfs (Windows/Linux)"
    echo "3) fat32 (Compatible universal)"
    echo
    echo "=== Sistemas de archivos avanzados ==="
    echo "4) btrfs (Sistema moderno con snapshots)"
    echo "5) xfs (Alto rendimiento para servidores)"
    echo "6) exfat (FAT64 - Para archivos >4GB)"
    echo
    echo "=== Sistemas especializados ==="
    echo "7) ext2 (Sin journaling, para USBs)"
    echo "8) ext3 (Con journaling básico)"
    echo "9) udf (Universal Disk Format)"
    echo "10) f2fs (Flash Friendly File System)"
    read -p "Seleccione una opción (1-10): " fs_option
    
    # Verificar si los paquetes necesarios están instalados
    check_and_install_package() {
        local cmd=$1
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "${YELLOW}El comando necesario '$cmd' no está instalado.${RESET}"
            
            # Detectar gestor de paquetes
            local pm="unknown"
            if command -v apt-get >/dev/null 2>&1; then
                pm="apt"
            elif command -v pacman >/dev/null 2>&1; then
                pm="pacman"
            elif command -v dnf >/dev/null 2>&1; then
                pm="dnf"
            elif command -v zypper >/dev/null 2>&1; then
                pm="zypper"
            fi

            # Mapear comando al paquete correspondiente
            local pkg=""
            case "$cmd" in
                mkfs.ntfs)
                    case "$pm" in
                        apt) pkg="ntfs-3g" ;;
                        pacman) pkg="ntfsprogs" ;;
                        *) pkg="ntfsprogs" ;;
                    esac
                    ;;
                mkfs.btrfs)
                    pkg="btrfs-progs"
                    ;;
                mkfs.xfs)
                    pkg="xfsprogs"
                    ;;
                mkfs.exfat)
                    pkg="exfatprogs"
                    ;;
                mkudffs)
                    pkg="udftools"
                    ;;
                mkfs.f2fs)
                    pkg="f2fs-tools"
                    ;;
                *)
                    pkg="$cmd"
                    ;;
            esac

            read -p "¿Desea instalar el paquete '$pkg'? (s/n): " install_choice
            if [[ $install_choice =~ ^[Ss]$ ]]; then
                case "$pm" in
                    apt)
                        sudo apt-get update && sudo apt-get install -y "$pkg"
                        ;;
                    pacman)
                        sudo pacman -S --noconfirm "$pkg"
                        ;;
                    dnf)
                        sudo dnf install -y "$pkg"
                        ;;
                    zypper)
                        sudo zypper install -y "$pkg"
                        ;;
                    *)
                        echo -e "${RED}Gestor de paquetes no soportado. Por favor, instale '$pkg' manualmente.${RESET}"
                        sleep 2
                        return 1
                        ;;
                esac
                
                if [ $? -ne 0 ]; then
                    echo -e "${RED}Error al instalar el paquete. Operación cancelada.${RESET}"
                    sleep 2
                    return 1
                fi
            else
                echo -e "${RED}No se puede continuar sin el paquete necesario.${RESET}"
                sleep 2
                return 1
            fi
        fi
        return 0
    }
    
    case $fs_option in
        1)
            fs_type="ext4"
            format_cmd="mkfs.ext4"
            format_opts="-F"  # Forzar formateo sin preguntar
            ;;
        2)
            fs_type="ntfs"
            check_and_install_package "mkfs.ntfs" || return
            format_cmd="mkfs.ntfs"
            format_opts="-f -Q"  # Formateo rápido
            ;;
        3)
            fs_type="vfat"
            format_cmd="mkfs.vfat"
            format_opts=""
            ;;
        4)
            fs_type="btrfs"
            check_and_install_package "mkfs.btrfs" || return
            format_cmd="mkfs.btrfs"
            format_opts="-f"  # Forzar formateo
            ;;
        5)
            fs_type="xfs"
            check_and_install_package "mkfs.xfs" || return
            format_cmd="mkfs.xfs"
            format_opts="-f"  # Forzar formateo
            ;;
        6)
            fs_type="exfat"
            check_and_install_package "mkfs.exfat" || return
            format_cmd="mkfs.exfat"
            format_opts=""
            ;;
        7)
            fs_type="ext2"
            format_cmd="mkfs.ext2"
            format_opts="-F"  # Forzar formateo
            ;;
        8)
            fs_type="ext3"
            format_cmd="mkfs.ext3"
            format_opts="-F"  # Forzar formateo
            ;;
        9)
            fs_type="udf"
            check_and_install_package "mkudffs" || return
            format_cmd="mkudffs"
            format_opts="--media-type=hd"  # Para discos duros
            ;;
        10)
            fs_type="f2fs"
            check_and_install_package "mkfs.f2fs" || return
            format_cmd="mkfs.f2fs"
            format_opts="-f"  # Forzar formateo
            ;;
        *)
            echo -e "${RED}Opción inválida. Operación cancelada.${RESET}"
            sleep 2
            return
            ;;
    esac
    
    # Opciones adicionales según el sistema de archivos
    if [[ "$fs_type" == "ext4" || "$fs_type" == "ext3" || "$fs_type" == "ext2" ]]; then
        echo -e "\n${CYAN}Opciones adicionales para $fs_type:${RESET}"
        read -p "¿Desea establecer una etiqueta? (s/n): " label_choice
        if [[ $label_choice =~ ^[Ss]$ ]]; then
            read -p "Ingrese la etiqueta (máx. 16 caracteres): " vol_label
            format_opts="$format_opts -L $vol_label"
        fi
        
        if [[ "$fs_type" == "ext4" ]]; then
            read -p "¿Desea habilitar el soporte de cifrado? (s/n): " encrypt_choice
            if [[ $encrypt_choice =~ ^[Ss]$ ]]; then
                format_opts="$format_opts -O encrypt"
            fi
        fi
    elif [[ "$fs_type" == "ntfs" ]]; then
        read -p "¿Desea establecer una etiqueta? (s/n): " label_choice
        if [[ $label_choice =~ ^[Ss]$ ]]; then
            read -p "Ingrese la etiqueta: " vol_label
            format_opts="$format_opts -L $vol_label"
        fi
    fi
    
    # Ejecutar el formateo
    echo -e "\n${YELLOW}Formateando dispositivo con sistema de archivos $fs_type...${RESET}"
    echo -e "${CYAN}Comando a ejecutar: $format_cmd $format_opts /dev/$device${RESET}"
    read -p "Presione Enter para continuar..."
    
    if sudo $format_cmd $format_opts "/dev/$device"; then
        echo -e "${GREEN}Formateo completado exitosamente.${RESET}"
        echo -e "${CYAN}Información del dispositivo formateado:${RESET}"
        lsblk -f "/dev/$device"
    else
        echo -e "${RED}Error durante el formateo.${RESET}"
    fi
    
    sleep 2
}

# Ejecutar la función
formatear_disco