#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [--pull] <vcpkg-directory>

Actualiza los ports locales desde un directorio vcpkg externo.

Opciones:
  --pull    Hace git pull en el directorio vcpkg antes de copiar los ports.

Argumentos:
  vcpkg-directory   Ruta al directorio raíz de vcpkg (debe contener la carpeta ports/).
EOF
    exit 1
}

DO_PULL=false
VCPKG_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pull)
            DO_PULL=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "Error: opción desconocida: $1"
            usage
            ;;
        *)
            if [[ -z "$VCPKG_DIR" ]]; then
                VCPKG_DIR="$1"
                shift
            else
                echo "Error: demasiados argumentos."
                usage
            fi
            ;;
    esac
done

if [[ -z "$VCPKG_DIR" ]]; then
    echo "Error: falta el directorio vcpkg."
    usage
fi

if [[ ! -d "$VCPKG_DIR" ]]; then
    echo "Error: '$VCPKG_DIR' no es un directorio válido."
    exit 1
fi

VCPKG_PORTS_DIR="$VCPKG_DIR/ports"
if [[ ! -d "$VCPKG_PORTS_DIR" ]]; then
    echo "Error: no se encontró la carpeta 'ports/' dentro de '$VCPKG_DIR'."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_PORTS_DIR="$SCRIPT_DIR/ports"

if [[ "$DO_PULL" == true ]]; then
    echo "==> Haciendo git pull en '$VCPKG_DIR'..."
    git -C "$VCPKG_DIR" pull
fi

echo "==> Copiando ports desde '$VCPKG_PORTS_DIR' hacia '$LOCAL_PORTS_DIR'..."
for port_dir in "$LOCAL_PORTS_DIR"/*/; do
    port_name="$(basename "$port_dir")"
    src_port="$VCPKG_PORTS_DIR/$port_name"
    if [[ -d "$src_port" ]]; then
        echo "  -> Actualizando '$port_name'..."
        rm -rf "$port_dir"
        cp -r "$src_port" "$LOCAL_PORTS_DIR/"
    else
        echo "  -> '$port_name' no existe en el origen, se omite."
    fi
done

echo "==> Actualización completada."
