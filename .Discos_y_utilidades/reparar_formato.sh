#!/bin/bash
# Linux Rembipuru - Suite de herramientas del sistema
# Autor: Elias Araujo
# Versión: BETA
# Script interactivo para desmontar, reparar y montar un disco

echo "=========================================="
echo "🧰 Reparador de discos Linux"
echo "=========================================="

# Mostrar discos y particiones disponibles
echo -e "\n🔍 Discos detectados:"
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT | grep -E "sd|nvme"

# Pedir el dispositivo
read -rp $'\n👉 Ingrese el nombre del dispositivo (ejemplo: sda1): ' DISCO

# Verificar existencia
if [ ! -b "/dev/$DISCO" ]; then
    echo "❌ El dispositivo /dev/$DISCO no existe."
    exit 1
fi

# Preguntar formato si no se detecta
FSTYPE=$(lsblk -no FSTYPE "/dev/$DISCO")
if [ -z "$FSTYPE" ]; then
    echo "⚠️ No se detectó el tipo de sistema de archivos."
    echo "Seleccione manualmente:"
    select FORMATO in ntfs ext4 ext3 ext2 exfat cancelar; do
        case $FORMATO in
            ntfs|ext4|ext3|ext2|exfat)
                FSTYPE=$FORMATO
                break
                ;;
            cancelar)
                echo "🚫 Operación cancelada."
                exit 0
                ;;
            *)
                echo "Opción inválida."
                ;;
        esac
    done
fi

echo -e "\n📦 Sistema de archivos: $FSTYPE"
MONTAJE="/mnt/reparacion_$DISCO"

# Crear punto de montaje
sudo mkdir -p "$MONTAJE"

# Desmontar si está montado
if mount | grep -q "/dev/$DISCO"; then
    echo "🔹 Desmontando /dev/$DISCO..."
    sudo umount "/dev/$DISCO"
fi

# Reparar según el tipo
case "$FSTYPE" in
    ntfs)
        echo "🧰 Reparando NTFS con ntfsfix..."
        if ! command -v ntfsfix >/dev/null 2>&1; then
            echo "Instalando herramientas de NTFS..."
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt update && sudo apt install -y ntfs-3g >/dev/null 2>&1
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm ntfsprogs >/dev/null 2>&1
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y ntfsprogs >/dev/null 2>&1
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y ntfsprogs >/dev/null 2>&1
            fi
        fi
        sudo ntfsfix "/dev/$DISCO"
        ;;
    ext4|ext3|ext2)
        echo "🧰 Reparando sistema Linux con fsck..."
        sudo fsck -f -y "/dev/$DISCO"
        ;;
    exfat)
        echo "🧰 Reparando exFAT con fsck.exfat..."
        if ! command -v fsck.exfat >/dev/null 2>&1; then
            echo "Instalando herramientas de exFAT..."
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt update && sudo apt install -y exfatprogs >/dev/null 2>&1
            elif command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm exfatprogs >/dev/null 2>&1
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y exfatprogs >/dev/null 2>&1
            elif command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y exfatprogs >/dev/null 2>&1
            fi
        fi
        sudo fsck.exfat -y "/dev/$DISCO"
        ;;
    *)
        echo "⚠️ Tipo de sistema $FSTYPE no soportado por este script."
        exit 1
        ;;
esac

# Montar de nuevo
echo "🔄 Montando temporalmente /dev/$DISCO en $MONTAJE..."
montado=false
if [ "$FSTYPE" = "ntfs" ] && command -v ntfs-3g >/dev/null 2>&1; then
    if sudo mount -t ntfs-3g "/dev/$DISCO" "$MONTAJE" >/dev/null 2>&1; then
        montado=true
    fi
fi

if [ "$montado" = false ]; then
    sudo mount "/dev/$DISCO" "$MONTAJE"
fi

# Confirmar
if mount | grep -q "/dev/$DISCO"; then
    sudo umount "/dev/$DISCO"
    echo -e "\n✅ El disco fue reparado, vuelva a montarlo en el sistema"
else
    echo -e "\n❌ No se pudo montar el disco. Revisa los mensajes anteriores."
    if [ "$FSTYPE" = "ntfs" ]; then
        echo "Nota: Si el disco tiene Windows Fast Startup o hibernación activa, el sistema"
        echo "de archivos estará protegido contra escritura y el kernel no lo montará."
        echo "Puedes intentar montarlo en modo de solo lectura (ro) o desactivar Inicio Rápido en Windows."
    fi
fi
