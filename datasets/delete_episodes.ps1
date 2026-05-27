# ── Borrar episodios de un dataset LeRobot (Windows) ─────────────────────────
# Uso (desde esta carpeta): .\delete_episodes.ps1
#
# Edita $EPISODES_TO_DELETE con los índices 0-based a eliminar.
# Por defecto actúa sobre el mismo repo que record_stack_cubes_joystick.ps1
# y vuelve a subir el dataset actualizado al Hub.
#
# Requiere: lerobot instalado (comando lerobot-edit-dataset en PATH)
#           HF_TOKEN con permiso de escritura si $PUSH_TO_HUB = $true

$ErrorActionPreference = "Stop"

# Mismo dataset que record_stack_cubes_joystick.ps1
$REPO_ID = "CarlosMunoz0/mujoco-so101-stack_cubes-joystick-v1"
$NEW_REPO_ID = "CarlosMunoz0/mujoco-so101-stack_cubes-joystick-v2"  # in-place en Hub; usa otro id si quieres conservar el original

# Índices de episodio a borrar (0 = primer episodio)
$EPISODES_TO_DELETE = @(4)

$PUSH_TO_HUB = $true
$CLEAR_LOCAL_CACHE = $true

if (-not $env:HF_TOKEN) {
    $env:HF_TOKEN = ""
}
if ($PUSH_TO_HUB -and -not $env:HF_TOKEN) {
    Write-Warning "HF_TOKEN vacío. Define `$env:HF_TOKEN o edítalo en este script antes de subir al Hub."
}

if ($EPISODES_TO_DELETE.Count -eq 0) {
    throw "Define al menos un índice en `$EPISODES_TO_DELETE (ej. @(0, 2))."
}

$episodeIndicesArg = "[" + ($EPISODES_TO_DELETE -join ", ") + "]"

$hfCache = Join-Path $env:USERPROFILE ".cache\huggingface"
$lerobotCache = Join-Path $hfCache ("lerobot\" + ($REPO_ID -replace "/", "\"))
$hubCache = Join-Path $hfCache ("hub\datasets--" + ($REPO_ID -replace "/", "--"))

if ($CLEAR_LOCAL_CACHE) {
    Write-Host "1. Limpiando caché local (evita datos obsoletos tras el borrado)..."
    foreach ($path in @($lerobotCache, $hubCache)) {
        if (Test-Path $path) {
            Remove-Item -LiteralPath $path -Recurse -Force
            Write-Host "   Eliminado: $path"
        }
    }
    Write-Host ""
}

Write-Host "2. Borrando episodios en Hub..."
Write-Host "   repo:     $REPO_ID"
Write-Host "   índices:  $episodeIndicesArg"
Write-Host "   subir:    $PUSH_TO_HUB"
Write-Host ""

$editArgs = @(
    "--repo_id", $REPO_ID,
    "--new_repo_id", $NEW_REPO_ID,
    "--operation.type", "delete_episodes",
    "--operation.episode_indices", $episodeIndicesArg,
    "--push_to_hub", $(if ($PUSH_TO_HUB) { "true" } else { "false" })
)

lerobot-edit-dataset @editArgs

if ($LASTEXITCODE -ne 0) {
    throw "lerobot-edit-dataset terminó con código $LASTEXITCODE"
}

Write-Host ""
Write-Host "Listo. Dataset actualizado:"
Write-Host "  https://huggingface.co/datasets/$NEW_REPO_ID"
if (Test-Path $lerobotCache) {
    Write-Host "  Local:  $lerobotCache"
}
