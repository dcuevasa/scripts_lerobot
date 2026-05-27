# ── Evaluar xVLA merged — push_cube_to_tray ───────────────────────────────────
# Escena: cubo en el suelo (y=0) → empujar hacia bandeja destino (y=0.25).
# XML dedicado: so101_push_cube_to_tray.xml
#
# Uso:
#   .\run_xvla_push_cube_to_tray.ps1

$ErrorActionPreference = "Stop"

$STEPS = 30000
$BATCH_SIZE = 16
$NUM_EPISODES_TRAIN = 400

$RUN_TAG = "${STEPS}step_bs${BATCH_SIZE}_ep${NUM_EPISODES_TRAIN}"
$POLICY_PATH = "Juanchix/xvla-so101-merged-4-tasks-${RUN_TAG}-v1.0"

$EVAL_REPO = "local/eval_xvla_push_cube_to_tray_${RUN_TAG}"
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
Write-Host "Tarea: Push the block into the tray"
Write-Host "Escena: cubo en suelo -> bandeja verde en y=0.25"
Write-Host ""

python (Join-Path $PSScriptRoot "run_xvla_merged.py") `
  --robot.type=so101_mujoco `
  --robot.xml_path="./robotstudio_so101/so101_push_cube_to_tray.xml" `
  --robot.randomize_scene=true `
  --robot.camera_pos_base="[0.5, 0.5, 0.6]" `
  --robot.camera_euler_base="[2.35619,0,-0.78539]" `
  --robot.box_pos_base="[0.35, 0.0, 0.04]" `
  --robot.box_pos_delta="[0.04, 0.05, 0.0]" `
  --robot.box_size_base="[0.02, 0.02, 0.03]" `
  --robot.box_size_delta="[0.005, 0.005, 0.005]" `
  --robot.box_color_base="[0.1, 0.1, 0.1, 1.0]" `
  --robot.box_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.tray_pos_base="[0.35, 0.25, 0.01]" `
  --robot.tray_pos_delta="[0.05, 0.05, 0.0]" `
  --robot.tray_size_base="[0.12, 0.12, 0.001]" `
  --robot.tray_size_delta="[0.02, 0.02, 0.0]" `
  --robot.tray_color_base="[0.1, 0.8, 0.1, 1.0]" `
  --robot.tray_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --robot.enable_rgb=true `
  --robot.enable_depth=false `
  --robot.enable_wrist_cam=false `
  --robot.enable_ee_pose=false `
  --robot.show_cv2=false `
  --dataset.repo_id=$EVAL_REPO `
  --dataset.single_task="Push the block into the tray" `
  --dataset.episode_time_s=300 `
  --dataset.num_episodes=1 `
  --dataset.reset_time_s=0 `
  --dataset.push_to_hub=false `
  '--dataset.rename_map={"observation.images.realsense": "observation.images.image"}' `
  --policy.path=$POLICY_PATH `
  --display_data=true

if ($LASTEXITCODE -ne 0) {
    throw "lerobot-record terminó con código $LASTEXITCODE"
}

Write-Host ""
Write-Host "Listo. Videos/parquet en: $HF_CACHE"
