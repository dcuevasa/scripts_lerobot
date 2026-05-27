# ── Podar dataset para entrenar ACT (Windows) ─────────────────────────────────
# Uso (desde esta carpeta): .\prune_dataset_act.ps1
#
# Origen:  dataset crudo subido con record_stack_cubes_joystick.ps1
# Salida:  copia en Hub sin depth y con state/action solo en joints (6D)
#
# Requiere: pip install huggingface_hub pandas pyarrow
#           HF_TOKEN con permiso de escritura en el repo de salida

$ErrorActionPreference = "Stop"

# Mismo token que en record_stack_cubes_joystick.ps1 (o $env:HF_TOKEN ya definido)
if (-not $env:HF_TOKEN) {
    $env:HF_TOKEN = ""
}
if (-not $env:HF_TOKEN) {
    Write-Warning "HF_TOKEN vacío. Define `$env:HF_TOKEN o edita este script antes de subir al Hub."
}

$INPUT_REPO  = "Celeste-02/mujoco-so101-cube_on_tray-joystick-v1"
$OUTPUT_REPO = "CarlosMunoz0/vla-mujoco-so101-cube_on_tray-joystick-v2.1"

$hfCache    = Join-Path $env:USERPROFILE ".cache\huggingface"
$lerobotOut = Join-Path $hfCache "lerobot\CarlosMunoz0\vla-mujoco-so101-cube_on_tray-joystick-v2.1"
$hubOut     = Join-Path $hfCache "hub\datasets--CarlosMunoz0--vla-mujoco-so101-cube_on_tray-joystick-v2.1"
$tempDir    = Join-Path $PSScriptRoot "..\temp_dataset_prune"

Write-Host "1. Limpiando caché local anterior (si existe)..."
foreach ($path in @($lerobotOut, $hubOut, $tempDir)) {
    if (Test-Path $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host "   Eliminado: $path"
    }
}

Write-Host "2. Ejecutando prune_dataset.py..."
Write-Host "   input:  $INPUT_REPO"
Write-Host "   output: $OUTPUT_REPO"

python (Join-Path $PSScriptRoot "..\..\FLAG-Embodied-data\prune_dataset.py") `
    --input_repo $INPUT_REPO `
    --output_repo $OUTPUT_REPO `
    --local_dir $tempDir `
    --drop_depth `
    --drop_ee

if ($LASTEXITCODE -ne 0) {
    throw "prune_dataset.py terminó con código $LASTEXITCODE"
}

Write-Host ""
Write-Host "Listo. Dataset publicado en:"
Write-Host "  https://huggingface.co/datasets/$OUTPUT_REPO"
Write-Host ""
Write-Host "Para entrenar ACT, usa en train:"
Write-Host "  --dataset.repo_id=$OUTPUT_REPO"
