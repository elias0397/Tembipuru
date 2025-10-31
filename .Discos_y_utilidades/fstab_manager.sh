#!/bin/bash
·
FSTAB="/etc/fstab"

while true; do
    clear
    echo "==== Gestor de fstab ===="
    echo "1) Ver fstab actual"
    echo "2) Editar fstab (elige editor)"
    echo "3) Salir"
    echo
    read -p "Seleccione una opción: " opcion
    case $opcion in
        1)
            echo "\n===== Contenido de $FSTAB ====="
            cat "$FSTAB"
            ;;
        2)
            echo "Se recomienda hacer una copia de seguridad antes de editar."
            echo "¿Qué editor deseas usar? (nano/vim) [nano]: "
            read -p "Editor: " editor
            editor=${editor,,} # minúsculas
            if [[ "$editor" == "vim" ]]; then
                sudo vim "$FSTAB"
            else
                sudo nano "$FSTAB"
            fi
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Opción inválida.";;
    esac
    echo
    read -p "Presione Enter para continuar..."
done
