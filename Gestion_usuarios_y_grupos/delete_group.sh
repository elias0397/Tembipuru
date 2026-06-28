#!/bin/bash
read -p "Nombre del grupo a eliminar: " grupo
if getent group "$grupo" &>/dev/null; then
    read -p "¿Está seguro de eliminar el grupo? (s/n): " confirma
    if [[ "$confirma" =~ ^[sS]$ ]]; then
        sudo delgroup "$grupo"
        [ $? = 0 ] && echo "Grupo $grupo eliminado."
    else
        echo "Operación cancelada."
    fi
else
    echo "El grupo no existe."
fi
