#!/bin/bash
echo "Usuarios del sistema:"
cut -d: -f1 /etc/passwd
