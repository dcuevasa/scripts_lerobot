# ── Grabación teleop (joystick) — push_cube_to_tray ───────────────────────────
# Escena: cubo en suelo (y=0) → bandeja destino verde (y=0.25).
# Para evaluar política: run_smolvla_push_cube_to_tray.ps1
#
# Uso:
#   .\record_push_cube_to_tray_joystick.ps1

$ErrorActionPreference = "Stop"

if (-not $env:HF_TOKEN) {
    $env:HF_TOKEN = ""
}

python (Join-Path $PSScriptRoot "..\..\FLAG-Embodied-data\lerobot_record_sim.py") `
  --robot.type=so101_mujoco `
  --robot.xml_path="./robotstudio_so101/so101_push_cube_to_tray.xml" `
  --robot.randomize_scene=true `
  --robot.camera_pos_base="[0.5, 0.5, 0.6]" `
  --robot.camera_euler_base="[2.35619,0,-0.78539]" `
  --robot.box_pos_base="[0.35, 0.0, 0.04]" `
  --robot.box_pos_delta="[0.04, 0.05, 0.0]" `
  --robot.box_size_base="[0.02, 0.02, 0.03]" `
  --robot.box_size_delta="[0.005, 0.005, 0.005]" `
  --robot.tray_pos_base="[0.35, 0.25, 0.01]" `
  --robot.tray_pos_delta="[0.05, 0.05, 0.0]" `
  --robot.tray_size_base="[0.12, 0.12, 0.001]" `
  --robot.tray_size_delta="[0.02, 0.02, 0.0]" `
  --robot.tray_color_base="[0.1, 0.8, 0.1, 1.0]" `
  --robot.tray_color_delta="[0.0, 0.0, 0.0, 0.0]" `
  --teleop.type=joystick `
  --teleop.linear_speed=0.003 `
  --teleop.angular_speed=0.025 `
  --teleop.gripper_speed=0.02 `
  --teleop.deadzone=0.08 `
  --dataset.repo_id="Celeste-02/mujoco-so101-push_cube_to_tray" `
  --dataset.single_task="Push the block into the tray" `
  --dataset.episode_time_s=25 `
  --dataset.num_episodes=10 `
  --reset_every_episode=true `
  --display_data=true `
  --resume=true

if ($LASTEXITCODE -ne 0) {
    throw "lerobot_record_sim terminó con código $LASTEXITCODE"
}
