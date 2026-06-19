#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_DIR="$(pwd)"

if [[ "$CURRENT_DIR" != "$SCRIPT_DIR" ]]; then
    echo "Error: este script debe ejecutarse desde su propia carpeta."
    echo "  Script location: $SCRIPT_DIR"
    echo "  Current directory: $CURRENT_DIR"
    exit 1
fi

if [[ -z "${VCPKG_HOME:-}" ]]; then
    echo "Error: VCPKG_HOME no está definida."
    exit 1
fi

VCPKG_PORTS_DIR="$VCPKG_HOME/ports"
if [[ ! -d "$VCPKG_PORTS_DIR" ]]; then
    echo "Error: no se encontró la carpeta 'ports/' dentro de '\$VCPKG_HOME'."
    exit 1
fi

LOCAL_PORTS_DIR="$SCRIPT_DIR/ports"

if [[ ! -d "$LOCAL_PORTS_DIR" ]]; then
    echo "Error: no se encontró la carpeta 'ports/' local."
    exit 1
fi

echo "==> Copiando ports desde '\$VCPKG_HOME/ports' hacia '$LOCAL_PORTS_DIR'..."
for port_dir in "$LOCAL_PORTS_DIR"/*/; do
    port_name="$(basename "$port_dir")"
    src_port="$VCPKG_PORTS_DIR/$port_name"
    if [[ -d "$src_port" ]]; then
        echo "  -> Actualizando '$port_name'..."
        rm -rf "$port_dir"/*
        cp -r "$src_port"/* "$port_dir"
    else
        echo "  -> '$port_name' no existe en el origen, se omite."
    fi
done

echo "==> Actualización completada."
