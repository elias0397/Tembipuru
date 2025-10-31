#!/bin/bash
read -p "Usuario a eliminar: " usuario
read -p "Grupo: " grupo
if sudo id "$usuario" &>/dev/null && getent group "$grupo" &>/dev/null; then
    sudo gpasswd -d "$usuario" "$grupo"
    [ $? = 0 ] && echo "Usuario eliminado del grupo."
else
    echo "Usuario o grupo no existentes."
fi
