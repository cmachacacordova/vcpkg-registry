# vcpkg-registry

Repositorio de registro privado para [`vcpkg`](https://vcpkg.io/). Contiene ports y triplets personalizados que se usan junto con una instalación estándar de vcpkg mediante `vcpkg-configuration.json`.

## Estructura

```
ports/       Ports modificados o personalizados
triplets/    Triplets custom (Linux, Windows, macOS)
update_ports.sh  Script helper para refrescar los ports desde una instalación local de vcpkg
```

## Ports del registro

> **Nota para agentes:** todos los ports de este registro se basan en ports oficiales de vcpkg, pero llevan modificaciones propias. Nunca asumas que son copias idénticas del upstream. Si vas a actualizar un port, revisa las diferencias funcionales listadas abajo y presérvalas.
> 
> Los ports marcados como **overlay manual** no se actualizan automáticamente con `update_ports.sh`/`update_ports.ps1`; deben mantenerse a mano.

| Port | Versión | Tipo de cambio principal |
|------|---------|--------------------------|
| `apr` | 1.7.6#1 | URL de descarga y `-fPIC` en Linux |
| `apr-util` | 1.6.3 | URL de descarga y `-fPIC` en Linux |
| `boost-url` | 1.92.0 | Visibilidad de símbolos `default` |
| `folly` | 2026.02.23.00#2 | `INTERFACE` en lugar de `PUBLIC` para `folly_detail_perf_scoped` |
| `glog` | 0.7.1#2 | Patch `visibility.patch`: visibilidad `default` |
| `libunwind` | 1.8.3#1 | `-fPIC` en `CFLAGS` |
| `log4cxx` | 1.8.0 | URL de descarga |
| `zlib` | 2.3.3 | **Overlay manual**: reemplaza `madler/zlib` por `zlib-ng/zlib-ng` en modo compatibilidad `ZLIB_COMPAT` |

### apr 1.7.6#1

- Cambia la URL de descarga del tarball de `downloads.apache.org` a `dlcdn.apache.org`.
- En plataformas no-Windows añade `-fPIC` a `CFLAGS` para que la biblioteca estática se pueda enlazar en shared objects.

### apr-util 1.6.3

- Cambia la URL de descarga del tarball de `archive.apache.org` a `dlcdn.apache.org`.
- Añade `-fPIC` a `CFLAGS` en plataformas no-Windows.

### boost-url 1.92.0

- Pasa `-DCMAKE_CXX_VISIBILITY_PRESET=default` y `-DCMAKE_C_VISIBILITY_PRESET=default` al build de Boost para evitar ocultar símbolos.

### folly 2026.02.23.00#2

- En `fix-perf_scoped-target.patch`, el target `folly_detail_perf_scoped` enlaza `folly_subprocess` como `INTERFACE` en lugar de `PUBLIC` bajo Linux.

### glog 0.7.1#2

- Añade el patch `visibility.patch` que cambia `CMAKE_C_VISIBILITY_PRESET` y `CMAKE_CXX_VISIBILITY_PRESET` de `hidden` a `default`.

### libunwind 1.8.3#1

- Añade `-fPIC` a `CFLAGS` antes de la configuración autotools.

### log4cxx 1.8.0

- Cambia la URL de descarga del tarball de `archive.apache.org` a `dlcdn.apache.org`.

### zlib 2.3.3

**Este es el cambio más importante del registro.**

- El port `zlib` ya no construye la implementación clásica (`madler/zlib`).
- Usa `zlib-ng/zlib-ng` versión `2.3.3` con `ZLIB_COMPAT=ON` para mantener compatibilidad API/ABI con zlib clásico.
- El portfile maneja nombres de salida (`zlib` / `zlibstatic` / variantes debug) y ajusta los archivos `.pc` de pkg-config.
- Los triplets de este registro definen `ZLIB_COMPAT=ON` para que los consumidores usen el modo compatible.

## Triplets

Los triplets viven en `triplets/` e incluyen configuraciones compartidas desde `triplets/configurations/`.

### Configuraciones base

- `triplets/configurations/linux-configuration.cmake`
  - Añade `-fPIC`, `-fvisibility=default`, `-Wno-maybe-uninitialized`.
  - Usa `lld` como linker (`-fuse-ld=lld`).
  - Fuerza `ZLIB_COMPAT=ON`.
  - Define `x86_64` como procesador y sistema `Linux`.

- `triplets/configurations/windows-configuration.cmake`
  - Fuerce `ZLIB_COMPAT=ON`.
  - Activa `CMAKE_EXPORT_COMPILE_COMMANDS`.

### Triplets disponibles

| Triplet | Plataforma | Enlace CRT | Enlace biblioteca | Notas |
|---------|------------|------------|-------------------|-------|
| `x64-linux` | Linux | dynamic | static | Base |
| `x64-linux-dynamic` | Linux | dynamic | dynamic | `VCPKG_FIXUP_ELF_RPATH=ON` |
| `x64-linux-release` | Linux | dynamic | static | Solo release |
| `x64-linux-clang` | Linux | dynamic | static | Compilador Clang |
| `x64-linux-clang-dynamic` | Linux | dynamic | dynamic | Clang + dynamic |
| `x64-linux-one-api` | Linux | dynamic | static | Intel oneAPI |
| `x64-linux-one-api-dynamic` | Linux | dynamic | dynamic | Intel oneAPI dynamic |
| `x64-windows-static-md` | Windows | dynamic | static | `/MD` con libs estáticas |
| `x64-windows-static-md-release` | Windows | dynamic | static | `/MD` + release only |
| `x64-windows-release` | Windows | dynamic | dynamic | Solo release |
| `x64-windows-clang` | Windows | dynamic | dynamic | Compilador Clang |
| `x64-uwp` | UWP | dynamic | dynamic | |
| `x64-osx` | macOS | dynamic | static | |
| `x64-osx-dynamic` | macOS | dynamic | dynamic | |

## Overlays manuales

Algunos ports de este registro no son "forks con parches" de un upstream existente, sino overlays completos que reemplazan un port de vcpkg por otro. Estos ports se mantienen a mano y **no deben ser sobrescritos** por `update_ports.sh` / `update_ports.ps1`.

| Port | Reemplazo | Razón |
|------|-----------|-------|
| `zlib` | `madler/zlib` → `zlib-ng/zlib-ng` | Usar `zlib-ng` con `ZLIB_COMPAT=ON` para mejor rendimiento manteniendo compatibilidad con `zlib` |

La lista de overlays manuales está codificada en las variables `MANUAL_PORTS` (bash) y `$ManualPorts` (PowerShell) de los scripts de actualización. Si se añade otro reemplazo similar, actualizar ambos scripts y esta tabla.

## Actualización de ports

Los scripts `update_ports.sh` y `update_ports.ps1` refrescan los ports locales copiando los archivos desde una instalación de vcpkg local. Requieren la variable de entorno `VCPKG_HOME`.

Bash:
```bash
VCPKG_HOME=/ruta/a/vcpkg ./update_ports.sh
```

PowerShell:
```powershell
$env:VCPKG_HOME = "C:\ruta\a\vcpkg"
.\update_ports.ps1
```

**Comportamiento:**
- Los ports listados en `MANUAL_PORTS` / `$ManualPorts` se omiten y se reportan como overlays manuales.
- El resto se sobrescribe completamente con la versión del upstream local.
- El script Bash copia el contenido de cada port mediante `cp -a "$src_port"/. "$port_dir"/`; el sufijo `/.` evita crear una subcarpeta duplicada dentro del destino y conserva los archivos ocultos.
- Al finalizar se imprime un resumen: ports actualizados, manuales y locales que no existen en upstream.
- Si un port local no existe en upstream, se advierte para que decidas si quitarlo del registro.
- **No se escribe ningún archivo de log**; las decisiones relevantes se registran en este `AGENTS.md`.

**Modo reporte (sin copiar):**

Bash:
```bash
VCPKG_HOME=/ruta/a/vcpkg ./update_ports.sh --dry-run
```

PowerShell:
```powershell
$env:VCPKG_HOME = "C:\ruta\a\vcpkg"
.\update_ports.ps1 -ReportOnly
```

**Precaución:** después de correr el script, revisa siempre el diff final para confirmar que los cambios/forks documentados arriba siguen intactos.

## Convenciones

- Si se añade un nuevo port basado en upstream, documenta aquí la razón del fork y los archivos modificados.
- Mantener `ZLIB_COMPAT=ON` en cualquier triplet nuevo o configuración compartida.
- Preferir `-fPIC` y `-fvisibility=default` en builds no-Windows para mantener compatibilidad con consumidores dinámicos.
- **Siempre informar al usuario** qué cambios se hicieron en los ports después de ejecutar `update_ports.sh` / `update_ports.ps1`, incluso si el resultado fue "sin cambios". El resumen debe incluir: ports actualizados, overlays manuales omitidos, y cualquier port local que no exista en upstream.
- **Todo cambio en `staged` debe reflejarse en `AGENTS.md`**: si hay archivos en `staged` que correspondan a una decisión, modificación de port, nuevo triplet o cualquier cambio relevante, actualiza este archivo antes o junto con el commit. No es necesario documentar cambios que aún no estén en `staged`.

## Decisiones del proyecto

Las decisiones importantes se registran en este archivo, no en archivos de log efímeros.
**Solo se documentan decisiones reflejadas en `staged`**: si hay archivos en `staged` que representen una decisión importante, actualiza `AGENTS.md` para reflejar esos cambios antes de hacer commit. No documentes decisiones que aún no estén en `staged` ni formen parte del repositorio.

- El script original `update_ports.sh` exigía ejecutarse desde su propia carpeta y no copiaba archivos ocultos. Se corrigió para poder invocarse desde cualquier lugar y copiar todo el contenido de cada port con `cp -a "$src_port"/. "$port_dir"/`, evitando que el directorio fuente se anide dentro del destino.
- Se creó `update_ports.ps1` para poder ejecutar la actualización desde Windows sin depender de Git Bash.
- `zlib` es un **overlay manual**: reemplaza el port upstream `madler/zlib` por `zlib-ng/zlib-ng` con `ZLIB_COMPAT=ON`. Por eso está en la lista `MANUAL_PORTS` / `$ManualPorts` y no se actualiza automáticamente.
- Los scripts imprimen un resumen al finalizar y soportan modo reporte (`--dry-run` / `-ReportOnly`) para revisar qué harían sin modificar archivos.
- Las decisiones de agregar o eliminar ports del registro deben reflejarse actualizando esta guía (`AGENTS.md`) y, si aplica, la lista de overlays manuales en los scripts.

## Skill para agentes: actualización de ports

> Esta sección es una guía de comportamiento que los agentes podemos seguir cuando detectemos que los ports necesitan actualizarse. Puede ignorarse si el usuario da instrucciones explícitas de otro modo.

Si durante una tarea detectas que uno o más ports de este registro podrían necesitar actualización —por ejemplo, porque hay un nuevo upstream, fallos de build, advertencias de CVE, el problema que reporta el usuario podría solucionarse actualizando los ports, se detectan cambios en los ports, o el usuario lo solicita—, **pregunta al usuario antes de ejecutar `update_ports.sh` o `update_ports.ps1`**.

Sigue este orden:

1. **Informa al usuario** qué port(s) quieres actualizar y por qué.
2. **Pregunta si quiere proseguir** con la actualización.
3. Si acepta, **verifica** que `VCPKG_HOME` apunta a una instalación local de vcpkg.
4. **Ejecuta** el script correspondiente y revisa el diff resultante para asegurarte de que los cambios/forks documentados se mantienen.
5. **Reporta** el resumen: ports actualizados, overlays manuales omitidos, y ports locales que no existan en upstream.

No ejecutes la actualización automáticamente sin confirmación.
