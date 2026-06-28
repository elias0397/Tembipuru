#!/bin/bash
read -p "Nombre de usuario a crear: " usuario
if sudo id "$usuario" &>/dev/null; then
    echo "El usuario ya existe."
else
    sudo adduser "$usuario"
    [ $? = 0 ] && echo "Usuario $usuario creado correctamente."
fi
