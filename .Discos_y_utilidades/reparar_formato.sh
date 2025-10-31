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
        sudo apt install -y ntfs-3g >/dev/null 2>&1
        sudo ntfsfix "/dev/$DISCO"
        ;;
    ext4|ext3|ext2)
        echo "🧰 Reparando sistema Linux con fsck..."
        sudo fsck -f -y "/dev/$DISCO"
        ;;
    exfat)
        echo "🧰 Reparando exFAT con fsck.exfat..."
        sudo apt install -y exfatprogs >/dev/null 2>&1
        sudo fsck.exfat -y "/dev/$DISCO"
        ;;
    *)
        echo "⚠️ Tipo de sistema $FSTYPE no soportado por este script."
        exit 1
        ;;
esac

# Montar de nuevo
echo "🔄 Montando /dev/$DISCO en $MONTAJE..."
sudo mount "/dev/$DISCO" "$MONTAJE"

# Confirmar
if mount | grep -q "/dev/$DISCO"; then
    echo -e "\n✅ El disco fue reparado y montado correctamente en $MONTAJE"
else
    echo -e "\n❌ No se pudo montar el disco. Revisa los mensajes anteriores."
fi
