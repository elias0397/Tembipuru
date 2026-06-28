#!/bin/bash
read -p "Nombre del grupo a crear: " grupo
if getent group "$grupo" &>/dev/null; then
    echo "El grupo ya existe."
else
    sudo addgroup "$grupo"
    [ $? = 0 ] && echo "Grupo $grupo creado correctamente."
fi
