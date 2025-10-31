#!/bin/bash
read -p "Nombre de usuario: " usuario
if sudo id "$usuario" &>/dev/null; then
    sudo passwd "$usuario"
else
    echo "El usuario no existe."
fi
