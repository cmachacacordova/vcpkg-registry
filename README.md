# Registro personalizado de vcpkg

Este repositorio contiene un registro personalizado (`vcpkg` registry) con puertos de ejemplo alojados en una estructura compatible con `vcpkg`.

## Estructura del repositorio

- `ports/` - cada subcarpeta es un port con su propio `portfile.cmake` y `vcpkg.json`.
- `versions/` - historial de versiones de los puertos, incluyendo `baseline.json` y las versiones registradas por port.
- `scripts/` - herramientas de mantenimiento, incluyendo `update-port` para actualizar puertos.

## Puertos disponibles

- `i18n-redis` - Biblioteca C++ de internacionalización con backend Redis.
- `pipes` - Biblioteca header-only para crear tuberías funcionales.
- `uuid-h` - Biblioteca de un solo archivo para generar UUIDs.

## Uso del registro en vcpkg

Para consumir este registro desde `vcpkg`, agrega una entrada en `vcpkg.json` o en `registries.json`:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/cmachacacordova/vcpkg-registry",
      "baseline": "versions/baseline.json"
    }
  ]
}
```

Luego instala el port deseado:

```sh
vcpkg install i18n-redis
```

## Cómo actualizar un port

Se incluye el script `scripts/update-port` para actualizar fácilmente un port existente.

### Sintaxis

```sh
./scripts/update-port <port-name> <repository> <ref> [version]
```

También es posible omitir `<repository>` y mantener el repositorio actual definido en el `portfile.cmake`:

```sh
./scripts/update-port <port-name> <ref> [version]
```

### Comportamiento

- Si se proporciona `version`, se actualiza el campo `version` en `vcpkg.json` y se elimina `version-string`.
- Si no se proporciona `version`, se actualiza `version-string` en `vcpkg.json` con el valor de `ref`.
- En todos los casos se actualiza la línea `REF` en `portfile.cmake`.
- Si hay una línea `SHA512` en `portfile.cmake`, también se actualiza con el hash del archivo fuente descargado desde GitHub.
- Si se proporciona `<repository>`, también se actualiza la línea `REPO` en `portfile.cmake`.

### Ejemplos

```sh
./scripts/update-port i18n-redis https://github.com/cmachacacordova/i18n-redis v0.3.2 0.3.2
./scripts/update-port i18n-redis v0.3.2
./scripts/update-port pipes https://github.com/joboccara/pipes v1.0.0
```

## Cómo actualizar la metadata del registro

Para un registro privado de puertos de `vcpkg`, la documentación oficial recomienda mantener el archivo `versions/baseline.json` y las entradas en `versions/<letra>-/<port>.json` actualizados.

Desde la raíz del repositorio del registro, usa el comando:

```sh
vcpkg --x-builtin-ports-root=./ports --x-builtin-registry-versions-dir=./versions x-add-version --verbose --overwrite-version <port-name> [<port-name1> <port-name2>]
```

Por ejemplo:

```sh
cd /ruta/al/repo/vcpkg-registry
vcpkg --x-builtin-ports-root=./ports --x-builtin-registry-versions-dir=./versions x-add-version --verbose --overwrite-version i18n-redis pipes
```

Para actualizar todos los puertos, usa el comando:

```sh
vcpkg --x-builtin-ports-root=./ports --x-builtin-registry-versions-dir=./versions x-add-version --all --verbose
```

Este comando actualiza la versión activa del port en `versions/baseline.json` y genera o actualiza la entrada correspondiente en `versions/i-/i18n-redis.json`.

Para un registro privado Git también debes asegurarte de que el `vcpkg.json` del consumidor o `registries.json` incluya la URL del repositorio y el `baseline`:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/cmachacacordova/vcpkg-registry",
      "baseline": "versions/baseline.json"
    }
  ]
}
```

## Cómo crear nuevos puertos

1. Crea un nuevo directorio en `ports/<nombre-del-port>`.
2. Añade el manifiesto `vcpkg.json` con los metadatos del port.
3. Crea `portfile.cmake` con una llamada a `vcpkg_from_github(...)` o la fuente que corresponda.
4. Si el port publica versiones, agrega la entrada en `versions/<letra>-/<nombre-del-port>.json` y actualiza `versions/baseline.json`.

### Buenas prácticas para puertos

- Cada port debe tener un solo `vcpkg.json` válido.
- Usa `version` para versiones semánticas conocidas.
- Usa `version-string` cuando la versión coincida con el `REF` usado en el código fuente.
- Mantén `portfile.cmake` lo más simple posible, con la descarga y configuración necesarias para construir e instalar el paquete.

## Estado actual del repositorio

### Puertos

- `i18n-redis`: manifest con `version` y un `portfile.cmake` que descarga desde GitHub.
- `pipes`: header-only, descargado desde GitHub, solo `release`, sin build de debug.
- `uuid-h`: port simple con descarga desde GitHub y copia del archivo `uuid.h`.

### Versiones

- `versions/baseline.json` define las versiones activas para cada port.
- `versions/i-/i18n-redis.json`, `versions/p-/pipes.json` y `versions/u-/uuid-h.json` contienen el historial de versiones del registro.

## Requisitos

- `vcpkg` instalado y configurado.
- Node.js para ejecutar `scripts/update-port` o permiso de ejecución en el archivo JS.

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta [LICENSE](LICENSE) para más detalles.
