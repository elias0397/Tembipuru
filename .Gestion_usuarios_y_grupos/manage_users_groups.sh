#!/bin/bash
# Menú de gestión de usuarios y grupos para Tembipuru

GEST_DIR="$(dirname "$0")"

while true; do
    clear
    echo "===== Gestión de Usuarios y Grupos ====="
    echo "1) Crear usuario"
    echo "2) Eliminar usuario"
    echo "3) Cambiar contraseña de usuario"
    echo "4) Crear grupo"
    echo "5) Eliminar grupo"
    echo "6) Añadir usuario a grupo"
    echo "7) Eliminar usuario de grupo"
    echo "8) Listar usuarios"
    echo "9) Listar grupos"
    echo "10) Salir"
    echo
    read -p "Seleccione una opción: " opcion
    case $opcion in
        1)
            bash "$GEST_DIR/create_user.sh"
            ;;
        2)
            bash "$GEST_DIR/delete_user.sh"
            ;;
        3)
            bash "$GEST_DIR/change_password.sh"
            ;;
        4)
            bash "$GEST_DIR/create_group.sh"
            ;;
        5)
            bash "$GEST_DIR/delete_group.sh"
            ;;
        6)
            bash "$GEST_DIR/add_user_to_group.sh"
            ;;
        7)
            bash "$GEST_DIR/del_user_from_group.sh"
            ;;
        8)
            bash "$GEST_DIR/list_users.sh"
            ;;
        9)
            bash "$GEST_DIR/list_groups.sh"
            ;;
        10)
            exit 0
            ;;
        *)
            echo "Opción inválida.";;
    esac
    echo
    read -p "Presione Enter para continuar..."
done
