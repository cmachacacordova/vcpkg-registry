#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=1
            shift
            ;;
        *)
            echo "Uso: $0 [--dry-run|-n]" >&2
            exit 1
            ;;
    esac
done

if [[ -z "${VCPKG_HOME:-}" ]]; then
    echo "Error: VCPKG_HOME no está definida." >&2
    echo "  Ejemplo: VCPKG_HOME=/ruta/a/vcpkg ./update_ports.sh" >&2
    exit 1
fi

if [[ ! -d "$VCPKG_HOME" ]]; then
    echo "Error: VCPKG_HOME no apunta a un directorio existente: '$VCPKG_HOME'" >&2
    exit 1
fi

VCPKG_HOME="$(cd "$VCPKG_HOME" && pwd)"
VCPKG_PORTS_DIR="$VCPKG_HOME/ports"
if [[ ! -d "$VCPKG_PORTS_DIR" ]]; then
    echo "Error: no se encontró la carpeta 'ports/' dentro de '\$VCPKG_HOME': '$VCPKG_PORTS_DIR'" >&2
    exit 1
fi

LOCAL_PORTS_DIR="$SCRIPT_DIR/ports"
if [[ ! -d "$LOCAL_PORTS_DIR" ]]; then
    echo "Error: no se encontró la carpeta 'ports/' local: '$LOCAL_PORTS_DIR'" >&2
    exit 1
fi

# Ports que son overlays manuales: NO se copian desde upstream.
# Cuando se agregue otro reemplazo (p. ej. un port cuyo nombre local
# difiere del upstream o que requiere tratamiento especial), añadirlo aquí.
declare -A MANUAL_PORTS=(
    [zlib]="overlay: reemplaza madler/zlib por zlib-ng/zlib-ng con ZLIB_COMPAT"
)

updated_ports=()
manual_ports=()
not_in_upstream=()

mode=""
if [[ "$DRY_RUN" -eq 1 ]]; then
    mode="[MODO REPORTE]"
fi

echo "==> $mode Copiando ports desde '$VCPKG_PORTS_DIR' hacia '$LOCAL_PORTS_DIR'..."

# Incluir archivos ocultos (.*) al expandir globs
shopt -s dotglob

for port_dir in "$LOCAL_PORTS_DIR"/*/; do
    port_name="$(basename "$port_dir")"
    src_port="$VCPKG_PORTS_DIR/$port_name"

    if [[ -n "${MANUAL_PORTS[$port_name]:-}" ]]; then
        echo "  -> '$port_name' es un overlay manual (${MANUAL_PORTS[$port_name]}), se omite."
        manual_ports+=("$port_name")
        continue
    fi

    if [[ -d "$src_port" ]]; then
        echo "  -> Actualizando '$port_name'..."
        updated_ports+=("$port_name")

        if [[ "$DRY_RUN" -eq 0 ]]; then
            rm -rf "$port_dir"
            mkdir -p "$port_dir"
            cp -a "$src_port"/ "$port_dir"
        fi
    else
        echo "  -> '$port_name' no existe en el origen, se omite."
        not_in_upstream+=("$port_name")
    fi
done

echo ""
echo "==> Resumen de actualización"
echo "    Actualizados  : ${#updated_ports[@]} -> ${updated_ports[*]-}"
echo "    Manuales      : ${#manual_ports[@]} -> ${manual_ports[*]-}"
echo "    No en upstream: ${#not_in_upstream[@]} -> ${not_in_upstream[*]-}"

if [[ ${#not_in_upstream[@]} -gt 0 ]]; then
    echo ""
    echo "ATENCION: los siguientes ports locales no existen en '$VCPKG_PORTS_DIR':" >&2
    for p in "${not_in_upstream[@]}"; do
        echo "  - $p" >&2
    done
    echo "Si fueron eliminados del upstream, considera quitarlos del registro y actualizar AGENTS.md." >&2
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
    echo ""
    echo "[REPORTE] No se realizaron cambios; solo se mostró el estado."
else
    echo "==> Actualización completada."
fi
