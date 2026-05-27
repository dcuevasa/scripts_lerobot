# ── Grabación teleop (mouse / so101_ik) — take_out_box ────────────────────────
# Misma escena que Juanchix/mujoco-so101-take_out_box-mouse-v1.0.
# Para evaluar una política entrenada, usa run_smolvla_take_out_box.ps1.
#
# Uso:
#   .\record_take_out_box_mouse.ps1

$ErrorActionPreference = "Stop"

if (-not $env:HF_TOKEN) {
    $env:HF_TOKEN = ""
}

python (Join-Path $PSScriptRoot "..\..\FLAG-Embodied-data\lerobot_record_sim.py") `
  --robot.type=so101_mujoco `
  --robot.randomize_scene=true `
  --robot.camera_pos_base="[0.5, 0.5, 0.6]" `
  --robot.camera_euler_base="[2.35619,0,-0.78539]" `
  --robot.tray_pos_base="[0.35, 0.0, 0.01]" `
  --robot.tray_pos_delta="[0.05, 0.05, 0.0]" `
  --robot.tray_size_base="[0.12, 0.12, 0.01]" `
  --robot.tray_size_delta="[0.02, 0.02, 0.0]" `
  --robot.box_pos_base="[0.35, 0.0, 0.04]" `
  --robot.box_pos_delta="[0.04, 0.05, 0.0]" `
  --robot.box_size_base="[0.02, 0.02, 0.02]" `
  --robot.box_size_delta="[0.005, 0.005, 0.0025]" `
  --robot.box2_pos_base="[0.0, 0.0, -10.0]" `
  --robot.box2_pos_delta="[0.0, 0.0, 0.0]" `
  --robot.box2_size_base="[0.001, 0.001, 0.001]" `
  --robot.box2_size_delta="[0.0, 0.0, 0.0]" `
  --robot.box2_color_base="[0.0, 0.0, 0.0, 0.0]" `
  --robot.box2_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --teleop.type=so101_ik `
  --dataset.repo_id="Juanchix/mujoco-so101-take_out_box-mouse-v1.0" `
  --dataset.single_task="Take the block out of the tray" `
  --dataset.episode_time_s=25 `
  --dataset.num_episodes=10 `
  --reset_every_episode=true `
  --display_data=false `
  --resume=true

if ($LASTEXITCODE -ne 0) {
    throw "lerobot_record_sim terminó con código $LASTEXITCODE"
}
