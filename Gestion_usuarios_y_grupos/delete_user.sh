#!/bin/bash
read -p "Nombre de usuario a eliminar: " usuario
if sudo id "$usuario" &>/dev/null; then
    read -p "¿Está seguro? Esta acción es irreversible (s/n): " confirma
    if [[ "$confirma" =~ ^[sS]$ ]]; then
        sudo deluser --remove-home "$usuario"
        [ $? = 0 ] && echo "Usuario $usuario eliminado."
    else
        echo "Operación cancelada."
    fi
else
    echo "El usuario no existe."
fi
