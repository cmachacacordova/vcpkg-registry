# vcpkg-registry

This repository hosts a simple custom registry for [vcpkg](https://github.com/microsoft/vcpkg). It contains a few demonstration ports that can be consumed through the `registries` feature of vcpkg.

## Ports

- **i18n-redis** – Example library using redis-plus-plus and nlohmann-json.
- **pipes** – Header-only pipeline library.
- **uuid-h** – Single-file library for UUID generation.

Each port provides its own `vcpkg.json` manifest. Once this registry is added to your configuration, you can install any port via `vcpkg install <port>`.

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.
