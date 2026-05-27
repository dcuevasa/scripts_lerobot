# ── [DEPRECADO] Script genérico de eval — reemplazado por run_smolvla_stack_cube.ps1 ──
# Este script evaluaba stack_cube sin xml_path explícito.
# Usar run_smolvla_stack_cube.ps1 en su lugar.
#
# Uso (legacy):
#   .\run_smolvla_merged.ps1

$ErrorActionPreference = "Stop"

# Solo cambia STEPS, BATCH_SIZE y NUM_EPISODES si usaste los mismos en modal_smolvla_finetune.py
$STEPS = 20000
$BATCH_SIZE = 16
$NUM_EPISODES = 400

$RUN_TAG = "${STEPS}step_bs${BATCH_SIZE}_ep${NUM_EPISODES}"

# Hub (por defecto) o ruta local, p. ej.:
#   .\checkpoints_last\pretrained_model
#   (tras: modal volume get smolvla-lerobot-outputs train/smolvla_merged_1000step_bs16_ep305/checkpoints/last ./checkpoints_last)
$POLICY_PATH = "CarlosMunoz0/smolvla-so101-merged-4-tasks-${RUN_TAG}-v2.1"

$EVAL_REPO = "local/eval_smolvla_merged_${RUN_TAG}"
$HF_CACHE = Join-Path $env:USERPROFILE ".cache\huggingface\lerobot\$EVAL_REPO"

if (Test-Path $HF_CACHE) {
    Remove-Item -LiteralPath $HF_CACHE -Recurse -Force
    Write-Host "Caché eval anterior eliminada: $HF_CACHE"
}

if (-not $env:HF_TOKEN) {
    $env:HF_TOKEN = ""
}

Write-Host "Política: $POLICY_PATH"
Write-Host "Eval dataset: $EVAL_REPO"
Write-Host ""

python (Join-Path $PSScriptRoot "run_smolvla_merged.py") `
  --robot.type=so101_mujoco `
  --robot.randomize_scene=true `
  --robot.camera_pos_base="[0.5, 0.5, 0.6]" `
  --robot.camera_euler_base="[2.35619,0,-0.78539]" `
  --robot.box_pos_base="[0.25, 0.08, 0.03]" `
  --robot.box_pos_delta="[0.06, 0.06, 0.0]" `
  --robot.box_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.box2_pos_base="[0.40, 0.05, 0.03]" `
  --robot.box2_pos_delta="[0.05, 0.05, 0.0]" `
  --robot.box2_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.tray_pos_base="[0.0, 0.0, -10.0]" `
  --robot.tray_pos_delta="[0.0, 0.0, 0.0]" `
  --robot.tray_size_base="[0.001, 0.001, 0.001]" `
  --robot.tray_size_delta="[0.0, 0.0, 0.0]" `
  --robot.tray_color_base="[0.0, 0.0, 0.0, 0.0]" `
  --robot.tray_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.enable_rgb=true `
  --robot.enable_depth=false `
  --robot.enable_wrist_cam=false `
  --robot.enable_ee_pose=false `
  --robot.show_cv2=false `
  --dataset.repo_id=$EVAL_REPO `
  --dataset.single_task="Stack the black cube on top of the blue cube" `
  --dataset.episode_time_s=1000 `
  --dataset.num_episodes=1 `
  --dataset.push_to_hub=false `
  '--dataset.rename_map={"observation.images.realsense": "observation.images.image"}' `
  --policy.path=$POLICY_PATH `
  --display_data=true

if ($LASTEXITCODE -ne 0) {
    throw "lerobot-record terminó con código $LASTEXITCODE"
}

Write-Host ""
Write-Host "Listo. Videos/parquet en: $HF_CACHE"
