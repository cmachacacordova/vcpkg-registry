#!/usr/bin/env pwsh
#Requires -Version 5.1

param(
    [Parameter(HelpMessage = "Ruta a la instalación de vcpkg")]
    [string]$VcpkgHome = $env:VCPKG_HOME,

    [Parameter(HelpMessage = "Solo reportar, no copiar")]
    [switch]$ReportOnly
)

$ErrorActionPreference = "Stop"

if (-not $VcpkgHome) {
    Write-Error "VCPKG_HOME no está definida.`nEjemplo: `$env:VCPKG_HOME = 'C:\vcpkg'; .\update_ports.ps1"
    exit 1
}

try {
    $VcpkgHome = (Resolve-Path $VcpkgHome).Path
} catch {
    Write-Error "VCPKG_HOME no apunta a un directorio existente: '$VcpkgHome'"
    exit 1
}

$VcpkgPortsDir = Join-Path $VcpkgHome "ports"
if (-not (Test-Path $VcpkgPortsDir -PathType Container)) {
    Write-Error "No se encontró la carpeta 'ports/' dentro de `$VCPKG_HOME`: $VcpkgPortsDir"
    exit 1
}

$ScriptDir = $PSScriptRoot
if (-not $ScriptDir) {
    # Fallback por si se ejecuta el script desde stdin
    $ScriptDir = (Get-Location).Path
}

$LocalPortsDir = Join-Path $ScriptDir "ports"
if (-not (Test-Path $LocalPortsDir -PathType Container)) {
    Write-Error "No se encontró la carpeta 'ports/' local: $LocalPortsDir"
    exit 1
}

# Ports que son overlays manuales: NO se copian desde upstream.
# Cuando se agregue otro reemplazo (p. ej. un port cuyo nombre local
# difiere del upstream o que requiere tratamiento especial), añadirlo aquí.
$ManualPorts = @{
    "zlib" = "overlay: reemplaza madler/zlib por zlib-ng/zlib-ng con ZLIB_COMPAT"
}

$updated = @()
$skipped = @()
$manual = @()
$notInUpstream = @()
$mode = if ($ReportOnly) { "[MODO REPORTE]" } else { "" }
Write-Host "==> $mode Copiando ports desde '$VcpkgPortsDir' hacia '$LocalPortsDir'..."

foreach ($portDir in Get-ChildItem -Path $LocalPortsDir -Directory) {
    $portName = $portDir.Name
    $srcPort = Join-Path $VcpkgPortsDir $portName
    $destPort = $portDir.FullName

    if ($ManualPorts.ContainsKey($portName)) {
        Write-Host "  -> '$portName' es un overlay manual ($($ManualPorts[$portName])), se omite."
        $manual += $portName
        continue
    }

    if (Test-Path $srcPort -PathType Container) {
        Write-Host "  -> Actualizando '$portName'..."
        $updated += $portName

        if (-not $ReportOnly) {
            # Eliminar el port local completo (incluyendo archivos ocultos)
            Remove-Item -Path $destPort -Recurse -Force
            New-Item -ItemType Directory -Path $destPort | Out-Null

            # Copiar todo el contenido, incluyendo archivos ocultos
            Get-ChildItem -Path $srcPort -Force | Copy-Item -Destination $destPort -Recurse -Force
        }
    } else {
        Write-Host "  -> '$portName' no existe en el origen, se omite."
        $notInUpstream += $portName
    }
}

Write-Host "`n==> Resumen de actualización"
Write-Host "    Actualizados  : $($updated.Count) -> $($updated -join ', ')"
Write-Host "    Manuales      : $($manual.Count) -> $($manual -join ', ')"
Write-Host "    No en upstream: $($notInUpstream.Count) -> $($notInUpstream -join ', ')"

if ($notInUpstream.Count -gt 0) {
    Write-Host "`nATENCION: los siguientes ports locales no existen en '$VcpkgPortsDir':" -ForegroundColor Yellow
    $notInUpstream | ForEach-Object { Write-Host "  - $_" }
    Write-Host "Si fueron eliminados del upstream, considera quitarlos del registro y actualizar AGENTS.md." -ForegroundColor Yellow
}

if ($ReportOnly) {
    Write-Host "`n[REPORTE] No se realizaron cambios; solo se mostró el estado." -ForegroundColor Cyan
} else {
    Write-Host "`n==> Actualización completada."
}
