# ── Fusionar varios datasets LeRobot v3 (ya podados) en uno solo ─────────────
# Uso: .\merge_datasets_act.ps1
#
# Descarga cada repo con snapshot_download (evita caché lerobot vacío/corrupto)
# y luego llama a lerobot-edit-dataset con --operation.roots explícitos.

$ErrorActionPreference = "Stop"

if (-not $env:HF_TOKEN) {
    $env:HF_TOKEN = ""
}

$REPO_IDS = @(
    "CarlosMunoz0/vla-mujoco-so101-stack_cubes-joystick-v2.1" # Mi repo con datos eliminados
    "CarlosMunoz0/vla-mujoco-so101-stack_cubes-mouse-v2.1" # repo de mi hecho por juanchix
    "CarlosMunoz0/vla-mujoco-so101-push_cube_to_tray-v2.1" # repo de carlos
    "CarlosMunoz0/vla-mujoco-so101-take_out_box-mouse-v2.1" # repo de juanchix
    "CarlosMunoz0/vla-mujoco-so101-cube_on_tray-joystick-v2.1" # repo de david hecho carlos
    "CarlosMunoz0/vla-mujoco-so101-cube_on_tray-mouse-v2.1" # repo de david hecho juanchix
)

$NEW_REPO_ID = "CarlosMunoz0/vla-mujoco-so101-merged-4-tasks-v2.1"
$PUSH_TO_HUB = $true

$mergeInputs = Join-Path $PSScriptRoot "merge_inputs"
$lerobotHome = Join-Path $env:USERPROFILE ".cache\huggingface\lerobot"
New-Item -ItemType Directory -Force -Path $mergeInputs | Out-Null

function Get-LocalDatasetDir([string]$RepoId) {
    $safe = $RepoId -replace "/", "__"
    return Join-Path $mergeInputs $safe
}

function Test-DatasetReady([string]$Dir) {
    return (Test-Path (Join-Path $Dir "meta\info.json"))
}

Write-Host "=== Paso 1: limpiar caché lerobot vacío (si existe) ==="
foreach ($repo in $REPO_IDS) {
    $badCache = Join-Path $lerobotHome ($repo -replace "/", "\")
    if ((Test-Path $badCache) -and -not (Test-Path (Join-Path $badCache "meta\info.json"))) {
        Remove-Item -LiteralPath $badCache -Recurse -Force
        Write-Host "   Eliminado caché incompleto: $badCache"
    }
}

Write-Host ""
Write-Host "=== Paso 2: descargar datasets a $mergeInputs ==="
foreach ($repo in $REPO_IDS) {
    $localDir = Get-LocalDatasetDir $repo
    if (Test-DatasetReady $localDir) {
        Write-Host "   OK (ya descargado): $repo"
        continue
    }
    if (Test-Path $localDir) {
        Remove-Item -LiteralPath $localDir -Recurse -Force
    }
    Write-Host "   Descargando: $repo ..."
    python -c @"
from huggingface_hub import snapshot_download
snapshot_download(
    repo_id='$repo',
    repo_type='dataset',
    local_dir=r'$localDir',
    local_dir_use_symlinks=False,
)
print('   ->', r'$localDir')
"@
    if (-not (Test-DatasetReady $localDir)) {
        throw "Descarga incompleta (falta meta/info.json): $repo"
    }
}

Write-Host ""
Write-Host "=== Paso 3: fusionar -> $NEW_REPO_ID ==="
$repoIdsArg = "['" + ($REPO_IDS -join "', '") + "']"
$roots = $REPO_IDS | ForEach-Object { Get-LocalDatasetDir $_ }
$rootsArg = "['" + (($roots | ForEach-Object { $_.Replace("\", "/") }) -join "', '") + "']"

foreach ($r in $REPO_IDS) { Write-Host "  - $r" }

$editArgs = @(
    "--new_repo_id", $NEW_REPO_ID,
    "--operation.type", "merge",
    "--operation.repo_ids", $repoIdsArg,
    "--operation.roots", $rootsArg,
    "--push_to_hub", $(if ($PUSH_TO_HUB) { "true" } else { "false" })
)

lerobot-edit-dataset @editArgs

if ($LASTEXITCODE -ne 0) {
    throw "lerobot-edit-dataset terminó con código $LASTEXITCODE"
}

$localOut = Join-Path $lerobotHome ($NEW_REPO_ID -replace "/", "\")
Write-Host ""
Write-Host "Listo."
Write-Host "  Hub:    https://huggingface.co/datasets/$NEW_REPO_ID"
Write-Host "  Local:  $localOut"
Write-Host "  Inputs: $mergeInputs (conservados para reintentos)"
Write-Host ""
Write-Host "Entrenar ACT: --dataset.repo_id=$NEW_REPO_ID"
