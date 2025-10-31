#!/bin/bash
read -p "Usuario a añadir: " usuario
read -p "Grupo destino: " grupo
if sudo id "$usuario" &>/dev/null && getent group "$grupo" &>/dev/null; then
    sudo usermod -aG "$grupo" "$usuario"
    [ $? = 0 ] && echo "Usuario añadido a grupo."
else
    echo "Usuario o grupo no existentes."
fi
