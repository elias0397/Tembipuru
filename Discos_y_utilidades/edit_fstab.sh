#!/bin/bash

FSTAB="/etc/fstab"
echo "Se recomienda hacer una copia de seguridad antes de editar."
echo "¿Qué editor deseas usar? (nano/vim) [nano]: "
read -p "Editor: " editor
editor=${editor,,} # a minúsculas
if [[ "$editor" == "vim" ]]; then
    sudo vim "$FSTAB"
else
    sudo nano "$FSTAB"
fi
